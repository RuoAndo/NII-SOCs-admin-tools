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

__global__ void sumArraysOnGPU(unsigned long long *A, int *B, int *C, const int N)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    // if (i < N) C[i] = A[i] / B[i];

    for(int i=0; i < N; i++)
    {
	if(A[idx] == A[i])
	{
		B[idx]++;
		C[i]=1;
	}
    }
}

__global__ void sumArraysOnGPU_2(unsigned long long *A, int *B, int *C, const int N)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    for(int i=0; i < N; i++)
    {
	if(A[idx] == A[i] && B[idx] == B[i])
	{
		C[idx] = A[idx];
	}
    }
}

int main( int argc, char* argv[] ) {

  int N = atoi(argv[2]);  
  unsigned int t, travdirtime; 
  int counter;
  
  size_t nBytes = N * sizeof(unsigned long long);
  size_t iBytes = N * sizeof(int);
  
  unsigned long long *h_timestamp;
  int *h_count;
  int *h_flag;

  h_timestamp = (unsigned long long *)malloc(nBytes);
  h_count = (int *)malloc(iBytes);
  h_flag = (int *)malloc(iBytes);

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
	    h_flag[row] = 0;

	    h_vec_timestamp[row] = stoull(timestamp.c_str());
	    h_vec_timestamp_count[row] = 1;
	  }

	  unsigned long long *d_timestamp;
	  int *d_count;
	  int *d_flag;
    	  cudaMalloc((unsigned long long**)&d_timestamp, nBytes);
    	  cudaMalloc((int**)&d_count, iBytes);
	  cudaMalloc((int**)&d_flag, iBytes);
 
	  cudaMemcpy(d_timestamp, h_timestamp, nBytes, cudaMemcpyHostToDevice);
    	  cudaMemcpy(d_count, h_count, iBytes, cudaMemcpyHostToDevice);
	  cudaMemcpy(d_flag, h_flag, iBytes, cudaMemcpyHostToDevice);

	  dim3 block (1);
          dim3 grid  (N);
	  
          start_timer(&t);  
          sumArraysOnGPU<<<grid, block>>>(d_timestamp, d_count, d_flag, N);
	  printf("Execution configure <<<%d, %d>>>\n", grid.x, block.x);
          travdirtime = stop_timer(&t);
          print_timer(travdirtime);


          cudaMemcpy(h_count, d_count, iBytes, cudaMemcpyDeviceToHost);
          cudaMemcpy(h_timestamp, d_timestamp, nBytes, cudaMemcpyDeviceToHost);
	  
	  thrust::device_vector<unsigned long long> dvec_tmp_1(N);
	  thrust::device_vector<int> dvec_tmp_2(N);

	  for(int i=0; i < N; i++)
	  {
		dvec_tmp_2[i] = h_count[i];
		dvec_tmp_1[i] = h_timestamp[i];
	  }

	  thrust::sort_by_key(dvec_tmp_1.begin(), dvec_tmp_1.end(), dvec_tmp_2.begin());
	  auto new_end_1 = thrust::unique_by_key(dvec_tmp_1.begin(), dvec_tmp_1.end(), dvec_tmp_2.begin());
	  long new_size_1 = new_end_1.first - dvec_tmp_1.begin();

	  for(int i=0 ; i< 4; i++)
	  	  std::cout << dvec_tmp_1[i] <<"," << dvec_tmp_2[i] << std::endl;

    	  cudaFree(d_timestamp);
    	  cudaFree(d_count);
	  cudaFree(d_flag);

	  std::remove("tmp");
	  ofstream outputfile("tmp");

	  counter = 0;
	  for(int i=0;i<N;i++)
	  {
		// outputfile << h_timestamp[i] << "," << h_count[i] << std::endl;
		if(h_count[i]!=0)
	        {
			outputfile << h_timestamp[i] << "," << h_count[i] << std::endl;
		        // counter++;
		}
	  }
	  outputfile.close();

          free(h_timestamp);
          free(h_count);
	  free(h_flag);

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

	  std::remove("tmp2");
	  ofstream outputfile2("tmp2");
	  
	  for(long i=0; i < new_size; i++)
	    {
	        /*
		if(std::to_string(dkey_out[i]).length()  == 17)
		{
			std::cout << dkey_out[i] << "," << dvalue_out[i] << endl;
	  	}
		*/
		outputfile2 << dkey_out[i] << "," << dvalue_out[i] << endl;
	    }

	  outputfile2.close();

	  // cudaDeviceReset();
   }
	  
   catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
   }
	
   // delete[] Data;       
   return 0;
}
