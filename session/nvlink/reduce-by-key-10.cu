#if __linux__ && defined(__INTEL_COMPILER)
#define __sync_fetch_and_add(ptr,addend) _InterlockedExchangeAdd(const_cast<void*>(reinterpret_cast<volatile void*>(ptr)), addend)
#endif
#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>   

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"
#include "utility.h"

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include "csv.hpp"
#include "timer.h"

using namespace tbb;
using namespace std;

std::vector<string> timestamp;

// data[], size, threads, blocks, 
void mergesort(long*, long*, long, dim3, dim3);
// A[]. B[], size, width, slices, nThreads
__global__ void gpu_mergesort(long*, long*, long*, long*, long, long, long, dim3*, dim3*);
__device__ void gpu_bottomUpMerge(long*, long*, long*, long*, long, long, long);

#define min(a, b) (a < b ? a : b)

__global__ void sumArraysOnGPU(long *A, long *B, long *C, long *D, const int N)
{
    // extern __shared__ long *shared_data[];

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    // int idx = threadIdx.x;
    
    for (int i = 0; i < N; ++i) {
    	if(A[idx]==A[i])
	{
	  // D[idx]++;
	  D[idx] += B[i];
	}
    }
    __syncthreads();

    for (int i = 0; i < N; ++i) {
    	if( A[idx]==A[i] && idx > i)
	{
	  C[idx]=0;
	}
    }
    __syncthreads();
}


int main(int argc, char** argv) {

    int N = atoi(argv[2]);

    dim3 threadsPerBlock;
    dim3 blocksPerGrid;

    threadsPerBlock.x = 32;
    threadsPerBlock.y = 1;
    threadsPerBlock.z = 1;

    blocksPerGrid.x = 8;
    blocksPerGrid.y = 1;
    blocksPerGrid.z = 1;

    const string csv_file = std::string(argv[1]); 
    vector<vector<string>> data; 

    // tm();

    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
       cout << "read ERROR" << endl;
       return 1;
       }

    long size=atoi(argv[2]);

    size_t nBytes = size * sizeof(long);
    long *data2;
    data2 = (long *)malloc(nBytes);

    size_t ullBytes = size * sizeof(unsigned long long);

    unsigned long long *data3;
    data3 = (unsigned long long *)malloc(ullBytes);

    long *value;
    value = (long *)malloc(nBytes);

    long *value_sorted;
    value_sorted = (long *)malloc(nBytes);

    long *value2;
    value2 = (long *)malloc(nBytes);     

    // counter = 0;
    for (unsigned int row = 0; row < data.size(); row++) {
    	vector<string> rec = data[row];
	std::string tms = rec[0];
	std::string bytes = rec[20];

	for(size_t c = tms.find_first_of("\""); c != string::npos; c = c = tms.find_first_of("\"")){
    	      tms.erase(c,1);
	}

	for(size_t c = tms.find_first_of("/"); c != string::npos; c = c = tms.find_first_of("/")){
	      tms.erase(c,1);
	}

        for(size_t c = tms.find_first_of("."); c != string::npos; c = c = tms.find_first_of(".")){
	      tms.erase(c,1);
	}

	for(size_t c = tms.find_first_of(" "); c != string::npos; c = c = tms.find_first_of(" ")){
	      tms.erase(c,1);
	}

	for(size_t c = tms.find_first_of(":"); c != string::npos; c = c = tms.find_first_of(":")){
	      tms.erase(c,1);
	}

	for(size_t c = bytes.find_first_of("\""); c != string::npos; c = c = bytes.find_first_of("\"")){
	      bytes.erase(c,1);
	}

	data2[row] = stol(tms);
	value[row] = stol(bytes);
    }

    for(int i = 0; i < 5; i++)
    	    cout << data2[i] << endl;
    
    std::cout << "sorting " << size << " numbers\n\n";
    
    // merge-sort the data
    mergesort(data2, value, size, threadsPerBlock, blocksPerGrid);

    /*
    for(int i = 0; i < 5; i++)
    	    cout << data2[i] << "," << value[i] << endl;
    */

    long *d_A;
    long *d_B;
    cudaMalloc((long**)&d_A, nBytes);
    cudaMalloc((long**)&d_B, nBytes);
    cudaMemcpy(d_A, data2, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, value, nBytes, cudaMemcpyHostToDevice);
    
    long *d_new_key, *d_new_value;
    cudaMalloc((long**)&d_new_key, nBytes);
    cudaMalloc((long**)&d_new_value, nBytes);
    cudaMemcpy(d_new_key, data2, nBytes, cudaMemcpyHostToDevice);

    int iLen = 1024;
    dim3 block (iLen);
    dim3 grid  ((N + block.x - 1) / block.x); 

    sumArraysOnGPU<<<grid, block>>>(d_A, d_B, d_new_key, d_new_value, size);

    long *gpuRef, *gpuRef2;
    
    gpuRef  = (long *)malloc(nBytes);
    cudaMemcpy(gpuRef, d_new_key, nBytes, cudaMemcpyDeviceToHost); 

    gpuRef2  = (long *)malloc(nBytes);
    cudaMemcpy(gpuRef2, d_new_value, nBytes, cudaMemcpyDeviceToHost); 

    int new_size = 0;
    for(int i = 0; i < N; i++)
    {
	if(gpuRef[i] != 0)
	{
	    cout << gpuRef[i] << "," << gpuRef2[i] << endl;     
	    new_size++;
	}
    }
}

void mergesort(long* data, long *value, long size, dim3 threadsPerBlock, dim3 blocksPerGrid) {

    //
    // Allocate two arrays on the GPU
    // we switch back and forth between them during the sort
    //
    long* D_data;
    long* D_swp;

    long* V_data;
    long* V_swp;
    
    dim3* D_threads;
    dim3* D_blocks;
    
    // Actually allocate the two arrays
    //tm();
    cudaMalloc((void**) &D_data, size * sizeof(long));
    cudaMalloc((void**) &D_swp, size * sizeof(long));

    cudaMalloc((void**) &V_data, size * sizeof(long));
    cudaMalloc((void**) &V_swp, size * sizeof(long));
    
        //std::cout << "cudaMalloc device lists: " << tm() << " microseconds\n";

    // Copy from our input list into the first array
    cudaMemcpy(D_data, data, size * sizeof(long), cudaMemcpyHostToDevice);
    cudaMemcpy(V_data, value, size * sizeof(long), cudaMemcpyHostToDevice);

        // std::cout << "cudaMemcpy list to device: " << tm() << " microseconds\n";
 
    //
    // Copy the thread / block info to the GPU as well
    //
    cudaMalloc((void**) &D_threads, sizeof(dim3));
    cudaMalloc((void**) &D_blocks, sizeof(dim3));

        // std::cout << "cudaMalloc device thread data: " << tm() << " microseconds\n";
    cudaMemcpy(D_threads, &threadsPerBlock, sizeof(dim3), cudaMemcpyHostToDevice);
    cudaMemcpy(D_blocks, &blocksPerGrid, sizeof(dim3), cudaMemcpyHostToDevice);

        // std::cout << "cudaMemcpy thread data to device: " << tm() << " microseconds\n";

    long* A = D_data;
    long* B = D_swp;

    long* C = V_data;
    long* D = V_swp;

    long nThreads = threadsPerBlock.x * threadsPerBlock.y * threadsPerBlock.z *
                    blocksPerGrid.x * blocksPerGrid.y * blocksPerGrid.z;

    //
    // Slice up the list and give pieces of it to each thread, letting the pieces grow
    // bigger and bigger until the whole list is sorted
    //
    for (int width = 2; width < (size << 1); width <<= 1) {
        long slices = size / ((nThreads) * width) + 1;

            std::cout << "mergeSort - width: " << width 
                      << ", slices: " << slices 
                      << ", nThreads: " << nThreads << '\n';
            // tm();

        // Actually call the kernel
        gpu_mergesort<<<blocksPerGrid, threadsPerBlock>>>(A, B, C, D, size, width, slices, D_threads, D_blocks);

            //std::cout << "call mergesort kernel: " << tm() << " microseconds\n";

        // Switch the input / output arrays instead of copying them around
        A = A == D_data ? D_swp : D_data;
        B = B == D_data ? D_swp : D_data;
    }

    //
    // Get the list back from the GPU
    //
    // tm();
    cudaMemcpy(data, A, size * sizeof(long), cudaMemcpyDeviceToHost);
    cudaMemcpy(value, D, size * sizeof(long), cudaMemcpyDeviceToHost);
        // std::cout << "cudaMemcpy list back to host: " << tm() << " microseconds\n";
    
    // Free the GPU memory
    cudaFree(A);
    cudaFree(B);
        //std::cout << "cudaFree: " << tm() << " microseconds\n";
}

// GPU helper function
// calculate the id of the current thread
__device__ unsigned int getIdx(dim3* threads, dim3* blocks) {
    int x;
    return threadIdx.x +
           threadIdx.y * (x  = threads->x) +
           threadIdx.z * (x *= threads->y) +
           blockIdx.x  * (x *= threads->z) +
           blockIdx.y  * (x *= blocks->z) +
           blockIdx.z  * (x *= blocks->y);
}

//
// Perform a full mergesort on our section of the data.
//
__global__ void gpu_mergesort(long* source, long* dest, long* value_src, long* value_dest, long size, long width, long slices, dim3* threads, dim3* blocks) {
    unsigned int idx = getIdx(threads, blocks);
    long start = width*idx*slices, 
         middle, 
         end;

    for (long slice = 0; slice < slices; slice++) {
        if (start >= size)
            break;

        middle = min(start + (width >> 1), size);
        end = min(start + width, size);
        gpu_bottomUpMerge(source, dest, value_src, value_dest, start, middle, end);
        start += width;
    }
}

//
// Finally, sort something
// gets called by gpu_mergesort() for each slice
//
__device__ void gpu_bottomUpMerge(long* source, long* dest, long* value_src, long* value_dest, long start, long middle, long end) {
    long i = start;
    long j = middle;
    for (long k = start; k < end; k++) {
        if (i < middle && (j >= end || source[i] < source[j])) {
            dest[k] = source[i];
	    value_dest[k] = value_src[i];
            i++;
        } else {
            dest[k] = source[j];
	    value_dest[k] = value_src[i];
            j++;
        }
    }
}

// read data into a minimal linked list
typedef struct {
    int v;
    void* next;
} LinkNode;

// helper function for reading numbers from stdin
// it's 'optimized' not to check validity of the characters it reads in..
long readList(long** list) {
    //tm();
    long v, size = 0;
    LinkNode* node = 0;
    LinkNode* first = 0;
    while (std::cin >> v) {
        LinkNode* next = new LinkNode();
        next->v = v;
        if (node)
            node->next = next;
        else 
            first = next;
        node = next;
        size++;
    }


    if (size) {
        *list = new long[size]; 
        LinkNode* node = first;
        long i = 0;
        while (node) {
            (*list)[i++] = node->v;
            node = (LinkNode*) node->next;
        }

    }

        //std::cout << "read stdin: " << tm() << " microseconds\n";

    return size;
}


// 
// Get the time (in microseconds) since the last call to tm();
// the first value returned by this must not be trusted
//
timeval tStart;
int tm() {
    timeval tEnd;
    gettimeofday(&tEnd, 0);
    int t = (tEnd.tv_sec - tStart.tv_sec) * 1000000 + tEnd.tv_usec - tStart.tv_usec;
    tStart = tEnd;
    return t;
}


