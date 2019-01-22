#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <cuda_runtime.h>
#include <stdio.h>
#define DIM 128

#include "csv.hpp"
#include "timer.h"
using namespace std;

extern __shared__ int dsmem[];

int recursiveReduce(int *data, int const size)
{
    if (size == 1) return data[0];

    int const stride = size / 2;

    for (int i = 0; i < stride; i++)
        data[i] += data[i + stride];

    return recursiveReduce(data, stride);
}

// unroll4 + complete unroll for loop + gmem
__global__ void reduceGmem(int *g_idata, int *g_odata, unsigned int n)
{
    // set thread ID
    unsigned int tid = threadIdx.x;
    int *idata = g_idata + blockIdx.x * blockDim.x;

    // boundary check
    unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx >= n) return;

    // in-place reduction in global memory
    if (blockDim.x >= 1024 && tid < 512) idata[tid] += idata[tid + 512];

    __syncthreads();

    if (blockDim.x >= 512 && tid < 256) idata[tid] += idata[tid + 256];

    __syncthreads();

    if (blockDim.x >= 256 && tid < 128) idata[tid] += idata[tid + 128];

    __syncthreads();

    if (blockDim.x >= 128 && tid < 64) idata[tid] += idata[tid + 64];

    __syncthreads();

    // unrolling warp
    if (tid < 32)
    {
        volatile int *vsmem = idata;
        vsmem[tid] += vsmem[tid + 32];
        vsmem[tid] += vsmem[tid + 16];
        vsmem[tid] += vsmem[tid +  8];
        vsmem[tid] += vsmem[tid +  4];
        vsmem[tid] += vsmem[tid +  2];
        vsmem[tid] += vsmem[tid +  1];
    }

    // write result for this block to global mem
    if (tid == 0) g_odata[blockIdx.x] = idata[0];
}

__global__ void reduceSmem(int *g_idata, int *g_odata, unsigned int n)
{
    __shared__ int smem[DIM];

    // set thread ID
    unsigned int tid = threadIdx.x;

    // boundary check
    unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx >= n) return;

    // convert global data pointer to the local pointer of this block
    int *idata = g_idata + blockIdx.x * blockDim.x;

    // set to smem by each threads
    smem[tid] = idata[tid];
    __syncthreads();

    // in-place reduction in shared memory
    if (blockDim.x >= 1024 && tid < 512) smem[tid] += smem[tid + 512];

    __syncthreads();

    if (blockDim.x >= 512 && tid < 256) smem[tid] += smem[tid + 256];

    __syncthreads();

    if (blockDim.x >= 256 && tid < 128) smem[tid] += smem[tid + 128];

    __syncthreads();

    if (blockDim.x >= 128 && tid < 64)  smem[tid] += smem[tid + 64];

    __syncthreads();

    // unrolling warp
    if (tid < 32)
    {
        volatile int *vsmem = smem;
        vsmem[tid] += vsmem[tid + 32];
        vsmem[tid] += vsmem[tid + 16];
        vsmem[tid] += vsmem[tid +  8];
        vsmem[tid] += vsmem[tid +  4];
        vsmem[tid] += vsmem[tid +  2];
        vsmem[tid] += vsmem[tid +  1];
    }

    // write result for this block to global mem
    if (tid == 0) g_odata[blockIdx.x] = smem[0];
}

__global__ void sumArraysOnGPU(unsigned long long *A, unsigned long long start_time, unsigned long long *C, int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) C[i] = (A[i] - start_time) / 3;
}

__global__ void sumArraysOnGPU_2(unsigned long long *A, unsigned long long start_time, unsigned long long *C, int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) C[i] = A[i] * 3 + start_time;
}

int main(int argc, char **argv)
{
    int N = atoi(argv[2]);

    unsigned int t, travdirtime; 

    int dev = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);
    printf("%s starting reduction at ", argv[0]);
    printf("device %d: %s ", dev, deviceProp.name);
    cudaSetDevice(dev);

    int size = N;

    // execution configuration
    // int blocksize = DIM;   // initial block size

    // dim3 block (blocksize, 1);
    // dim3 grid  ((size + block.x - 1) / block.x, 1);
    // printf("grid %d block %d\n", grid.x, block.x);

    // allocate host memory
    size_t bytes = size * sizeof(unsigned long long);
    unsigned long long *h_idata = (unsigned long long *) malloc(bytes);
    // unsigned long long *h_odata = (unsigned long long *) malloc(grid.x * sizeof(long));
    unsigned long long *h_odata = (unsigned long long *) malloc(bytes);
    unsigned long long *h_odata_2 = (unsigned long long *) malloc(bytes);
    
    const string csv_file = std::string(argv[1]); 
    vector<vector<string>> data; 

    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
     std::cout << "read ERROR" << std::endl;
     return 1;
    }

    for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 
      h_idata[row] = stoull(rec[0]);
    }

    // allocate device memory
    unsigned long long *d_idata = NULL;
    unsigned long long *d_odata = NULL;
    unsigned long long *d_odata_2 = NULL;

    cudaMalloc((unsigned long long **)&d_idata, bytes);
    // cudaMalloc((void **) &d_odata, grid.x * sizeof(int));
    cudaMalloc((unsigned long long **) &d_odata, bytes);
    cudaMalloc((unsigned long long **) &d_odata_2, bytes);

    // unsigned long long start_time = 20190109000000000;
    unsigned long long start_time = 20190109000000000;

    start_timer(&t); 
    cudaMemcpy(d_idata, h_idata, bytes, cudaMemcpyHostToDevice);
    sumArraysOnGPU<<<1, N>>>(d_idata, start_time, d_odata, N);    
    cudaMemcpy(h_odata, d_odata, bytes, cudaMemcpyDeviceToHost);
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    start_timer(&t); 
    cudaMemcpy(d_odata, h_odata, bytes, cudaMemcpyHostToDevice);
    sumArraysOnGPU_2<<<1, N>>>(d_odata, start_time, d_odata_2, N);    
    cudaMemcpy(h_odata_2, d_odata_2, bytes, cudaMemcpyDeviceToHost);
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    cout << "writing file..." << endl;
    std::remove("tmp");
    ofstream outputfile("tmp"); 

    start_timer(&t); 
    for(int i = 0; i < 10; i++)
        std::cout << h_idata[i] << "," << h_odata[i] << "," << h_odata_2[i] << std::endl;

    outputfile.close();

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    // free host memory
    free(h_idata);
    free(h_odata);
    free(h_odata_2);

    // free device memory
    cudaFree(d_idata);
    cudaFree(d_odata);
    cudaFree(d_odata_2);

    // reset device
    cudaDeviceReset();

    return EXIT_SUCCESS;
}
