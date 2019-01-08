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
#include <map>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "csv.hpp"
#include "timer.h"

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include "util.h"

using namespace std;
// static MyString* Data;

__global__ void bitonic_sort(unsigned long long *data, int data_size, int chunk_size, int sub_chunk_size, int *key)
{
    // int thread_index = blockDim.x * blockIdx.x + threadIdx.x;
    int thread_index = threadIdx.x;

    if (thread_index < data_size / 2) {
            int half_chunk_size = chunk_size / 2;
	            int chunk_index = thread_index / half_chunk_size;

        int half_sub_chunk_size = sub_chunk_size / 2;
	        int sub_chunk_index = thread_index / half_sub_chunk_size;

        bool up = (chunk_index % 2 == 0);
	        int a = sub_chunk_size * sub_chunk_index + thread_index % half_sub_chunk_size;
		int b = a + half_sub_chunk_size;

        unsigned long long va = data[a];
	        unsigned long long vb = data[b];
		        if (va > vb == up) {
			            data[a] = vb;
				    data[b] = va;
				    key[a] = key[b];
		}
	}
}

__global__ void sumArraysOnGPU(unsigned long long *A, int *B, const int N)
{
    // __shared__ extern int F[];

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    // int idx = threadIdx.x;

    for(int i=0; i < N; i++)
    {
	if(A[idx] == A[i])
	{
		B[idx]++;
	}
    }

    // __syncthreads();
    // B[idx] = F[idx];
}

__device__ void gpu_bottomUpMerge(unsigned long long* source, unsigned long long* dest,
                                  long start, long middle,
				  long end, int *skeys, int *dkeys) {
     int idx = blockIdx.x * blockDim.x + threadIdx.x;
     long i = start;
     long j = middle;

     for (long k = start; k < end; k++) {
     	 if (i < middle && (j >= end || source[i] < source[j])) {
	    dest[k] = source[i];
	    dkeys[k] = skeys[i];
	    i++;
	    }
	 else {
     	    dest[k] = source[j];
     	    j++;
     	    }
     }
}

__global__ void gpu_mergesort(unsigned long long* source, unsigned long long* dest, long size,
                              long width, long slices, int *dkeys, int *skeys) {
			      
   int idx = blockIdx.x * blockDim.x + threadIdx.x;
   long start = width*idx*slices, middle, end;

    for (long slice = 0; slice < slices; slice++) {
            if (start >= size)
	                break;
	    middle = min(start + (width >> 1), size);
	    end = min(start + width, size);
	    gpu_bottomUpMerge(source, dest, start, middle, end, dkeys, skeys);
	    start += width;
	    }
}

int main( int argc, char* argv[] ) {

  int N = atoi(argv[2]);  
  unsigned int t, travdirtime; 
  
  size_t nBytes = N * sizeof(unsigned long long);
  size_t iBytes = N * sizeof(int);

  unsigned long long *h_timestamp;
  int *h_count;
  h_timestamp = (unsigned long long *)malloc(nBytes);
  h_count = (int *)malloc(iBytes);

  unsigned long long *s_timestamp;
  int *s_count;
  s_timestamp = (unsigned long long *)malloc(nBytes);
  s_count = (int *)malloc(iBytes);

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  thrust::host_vector<unsigned long long> h_vec_timestamp(N);
  thrust::host_vector<int> h_vec_timestamp_count(N);

  try {
      	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	    }

	  for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row];

	    std::string timestamp = rec[0];

	    for(size_t c = timestamp.find_first_of("\""); c != string::npos; c = c = timestamp.find_first_of("\"")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of("."); c != string::npos; c = c = timestamp.find_first_of(".")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of(" "); c != string::npos; c = c = timestamp.find_first_of(" ")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of(":"); c != string::npos; c = c = timestamp.find_first_of(":")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of("/"); c != string::npos; c = c = timestamp.find_first_of("/")){
	      timestamp.erase(c,1);
	    }

	    h_timestamp[row] = stoull(timestamp.c_str());
	    h_count[row] = 1;

	    h_vec_timestamp[row] = stoull(timestamp.c_str());
	    h_vec_timestamp_count[row] = 1;
	  }

	  unsigned long long *d_timestamp, *timestamp_s;
	  int *d_count, *count_s;
	  
    	  cudaMalloc((unsigned long long**)&d_timestamp, nBytes);
	  cudaMalloc((unsigned long long**)&timestamp_s, nBytes);
    	  cudaMalloc((int**)&d_count, iBytes);
	  cudaMalloc((int**)&count_s, iBytes);
 
	  cudaMemcpy(d_timestamp, h_timestamp, nBytes, cudaMemcpyHostToDevice);
    	  cudaMemcpy(d_count, h_count, iBytes, cudaMemcpyHostToDevice);

	  dim3 block(1);
          dim3 grid(N);

          start_timer(&t);  
          sumArraysOnGPU<<<grid, block>>>(d_timestamp, d_count, N);
	  printf("Execution configure <<<%d, %d>>>\n", grid.x, block.x);
          travdirtime = stop_timer(&t);
          print_timer(travdirtime);

          cudaMemcpy(h_timestamp, d_timestamp, nBytes, cudaMemcpyDeviceToHost);
	  cudaMemcpy(h_count, d_count, iBytes, cudaMemcpyDeviceToHost);

	  /*
	  for(int i = 0; i < 5; i++)
	  	  cout << h_timestamp[i] << "," << h_count[i] << endl;	
          */

	  gpu_mergesort<<<grid, block>>>(d_timestamp, timestamp_s, N, N/10, N/10, d_count, count_s);
          cudaMemcpy(s_timestamp, timestamp_s, nBytes, cudaMemcpyDeviceToHost);
	  cudaMemcpy(s_count, count_s, iBytes, cudaMemcpyDeviceToHost);

	  for(int i = 0; i < 10; i++)
	  	  cout << s_timestamp[i] << "," << s_count[i] << endl;
		  
	  /*
	  bitonic_sort<<<grid, block>>>(d_timestamp, N, 1000, 100, d_count);	  
          cudaMemcpy(h_timestamp, d_timestamp, nBytes, cudaMemcpyDeviceToHost);
	  cudaMemcpy(h_count, d_count, iBytes, cudaMemcpyDeviceToHost);

	  for(int i = 0; i < 3; i++)
	  	  cout << h_timestamp[i] << "," << h_count[i] << endl;
          */

    	  cudaFree(d_timestamp);
    	  cudaFree(d_count);

          free(h_timestamp);
          free(h_count);
		
	  /*
          start_timer(&t);  

	  thrust::device_vector<unsigned long long> key_in = h_vec_timestamp;
	  thrust::device_vector<int> value_in = h_vec_timestamp_count;

	  thrust::sort(key_in.begin(), key_in.end());

	  thrust::device_vector<unsigned long long> dkey_out(N,0);
	  thrust::device_vector<int> dvalue_out(N,0);
	  
	  auto new_end = thrust::reduce_by_key(key_in.begin(),
					       key_in.end(),
					       value_in.begin(),
					       dkey_out.begin(),
	  				       dvalue_out.begin());

	  long new_size = new_end.first - dkey_out.begin();

          travdirtime = stop_timer(&t);
	  print_timer(travdirtime);
	  
	  for(int i = 0; i < 3; i++)
		cout << dkey_out[i] << "," << dvalue_out[i] << endl;
	  */

	  /*
	  std::remove("tmp2");
	  ofstream outputfile2("tmp2");
	  
	  for(long i=0; i < new_size; i++)
	    {
		outputfile2 << dkey_out[i] << "," << dvalue_out[i] << endl;
	    }

	  outputfile2.close();
	  */

	  // cudaDeviceReset();
   }
	  
   catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
   }
	
   // delete[] Data;       
   return 0;
}
