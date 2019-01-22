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

void sumArraysOnHost(int *A, int *B, float *C, const int N)
{
    for (int idx = 0; idx < N; idx++)
    {
        C[idx] = A[idx] / B[idx];
    }
}

__global__ void sumArraysOnGPU(int *A, int *B, float *C, const int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) C[i] = A[i] / B[i];
}

int main( int argc, char* argv[] ) {

  int N = atoi(argv[2]);  
  unsigned int t, travdirtime; 

  size_t nBytes = N * sizeof(int);
  size_t fBytes = N * sizeof(float);

  int *h_Recv, *h_nRecv;
  float *h_C;
  
  h_Recv = (int *)malloc(nBytes);
  h_nRecv = (int *)malloc(nBytes);
  h_C = (float *)malloc(fBytes);

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  try {
      	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	    }

	  for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row];

	    for(size_t c = rec[17].find_first_of("\""); c != string::npos; c = c = rec[17].find_first_of("\"")){
	      rec[17].erase(c,1);
	      }

	    for(size_t c = rec[20].find_first_of("\""); c != string::npos; c = c = rec[20].find_first_of("\"")){
	      rec[20].erase(c,1);
	      }

	    h_nRecv[row] = atoi(rec[17].c_str());
	    h_Recv[row] = atoi(rec[20].c_str());
	  }

	  int *d_Recv, *d_nRecv;
	  float *d_C;
    	  cudaMalloc((int**)&d_Recv, nBytes);
    	  cudaMalloc((int**)&d_nRecv, nBytes);
    	  cudaMalloc((float**)&d_C, fBytes);

	  cudaMemcpy(d_Recv, h_Recv, nBytes, cudaMemcpyHostToDevice);
    	  cudaMemcpy(d_nRecv, h_nRecv, nBytes, cudaMemcpyHostToDevice);

          start_timer(&t);  
	  sumArraysOnHost(h_Recv, h_nRecv, h_C, N);
          travdirtime = stop_timer(&t);
          print_timer(travdirtime);

	  for(int i=0;i<5;i++)
		printf("%d %d %f \n", h_Recv[i], h_nRecv[i], h_C[i]);

	  dim3 block (1);
          dim3 grid  (N);
	  
          start_timer(&t);  
          sumArraysOnGPU<<<grid, block>>>(d_Recv, d_nRecv, d_C, N);
          printf("Execution configure <<<%d, %d>>>\n", grid.x, block.x);
          travdirtime = stop_timer(&t);
          print_timer(travdirtime);

          cudaMemcpy(h_C, d_C, nBytes, cudaMemcpyDeviceToHost);

    	  cudaFree(d_Recv);
    	  cudaFree(d_nRecv);
    	  cudaFree(d_C);

	  for(int i=0;i<5;i++)
		printf("%d %d %f \n", h_Recv[i], h_nRecv[i], h_C[i]);

          free(h_Recv);
          free(h_nRecv);

	  cudaDeviceReset();


   }
   catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
   }
	
   // delete[] Data;       
   return 0;
}
