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

__global__ void sumArraysOnGPU(unsigned long long *A, long *B, long *C, const int N)
{
    // extern __shared__ long *shared_data[];

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    // int idx = threadIdx.x;
    
    for (int i = 0; i < N; ++i) {
    	if(A[idx]==A[i])
	{
	  C[idx]++;
	}
    }
    __syncthreads();
}

int main( int argc, char* argv[] ) {

  int counter = 0;
  int N = atoi(argv[2]);  

  const size_t ullBytes = N * sizeof(unsigned long long);  
  const size_t lBytes = N * sizeof(long);  

  unsigned long long *h_A;
  long *h_B;  

  h_A = (unsigned long long *)malloc(ullBytes);
  h_B = (long *)malloc(lBytes);

  thrust::host_vector<unsigned long long> h_key_in_all(N);
  thrust::host_vector<long> h_value_in_all(N);

  unsigned int t, travdirtime; 

  int ngpus = 4;

    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

 	unsigned long long **d_k_i = (unsigned long long **)malloc(sizeof(unsigned long long *) * ngpus);
  	long **d_v_i = (long **)malloc(sizeof(long *) * ngpus);

 	unsigned long long **h_k_i = (unsigned long long **)malloc(sizeof(unsigned long long *) * ngpus);
  	long **h_v_i = (long **)malloc(sizeof(long *) * ngpus);
	
  	cudaStream_t *stream = (cudaStream_t *)malloc(sizeof(cudaStream_t) * ngpus); 

  	for (int i = 0; i < ngpus; i++)
  	{
	   cudaSetDevice(i);
           cudaMalloc((void **) &d_k_i[i], ullBytes);
	   cudaMalloc((void **) &d_v_i[i], lBytes);
	   cudaMallocHost((void **) &h_k_i[i], ullBytes);
	   cudaMallocHost((void **) &h_v_i[i], lBytes);	
	   cudaStreamCreate(&stream[i]);
  	}                  

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  counter = 0;
	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string tms = rec[0];

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

	   h_A[row] = stoull(tms);
      	   h_B[row] = 1;

	   if(counter < N/2) {
		h_k_i[0][counter] = stoull(tms);
      	   	h_v_i[0][counter] = 1;
	   }

	   if(counter > N/2) {
		h_k_i[1][counter] = stoull(tms);
      	   	h_v_i[1][counter] = 1;
	   }

	   counter = counter + 1;

	  }

	  int iLen = 1024;
	  dim3 block (iLen);
	  dim3 grid  ((N + block.x - 1) / block.x); 

	  cudaSetDevice(0);
	  cudaMemcpyAsync(d_k_i[0], h_k_i[0], N/2, cudaMemcpyHostToDevice, stream[0]);
	  cudaMemcpyAsync(d_v_i[0], h_v_i[0], N/2, cudaMemcpyHostToDevice, stream[0]);
	  cudaStreamSynchronize(stream[0]);

	  unsigned long long *d_A;
	  long *d_B;
	  cudaMalloc((unsigned long long**)&d_A, ullBytes);
	  cudaMalloc((long**)&d_B, lBytes);

	  cudaMemcpy(d_A, h_k_i[0], ullBytes, cudaMemcpyHostToDevice);
	  cudaMemcpy(d_B, h_v_i[0], lBytes, cudaMemcpyHostToDevice);

	  long *sum, *gpuRef;
	  
	  cudaMalloc((long**)&sum, lBytes);

	  sumArraysOnGPU<<<grid, block>>>(d_A, d_B, sum, N);

	  gpuRef  = (long *)malloc(lBytes);
	  cudaMemcpy(gpuRef, sum, lBytes, cudaMemcpyDeviceToHost); 

	  for(int i = 0; i < 10; i++)
	  {
		    cout << h_k_i[0][i] << "," << gpuRef[i] <<"," << h_v_i[0][i] << endl;
          }

	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}

        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
