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

void sumArraysOnHost(float *A, float *B, float *C, const int N)
{
    for (int idx = 0; idx < N; idx++)
    {
        C[idx] = A[idx] + B[idx];
    }
}

__global__ void sumArraysOnGPU(float *A, float *B, float *C, const int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) C[i] = A[i] + B[i];
}

int main( int argc, char* argv[] ) {

  int N = atoi(argv[2]);  
  std::string timestamp;

  int counter = 0;
  std::map<unsigned long long, int> mp;  

  size_t nBytes = N * sizeof(int);

  int *h_recv;
  h_recv = (int *)malloc(nBytes);

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
	    h_recv[row] = atoi(rec[17].c_str());
	  }
	  
   }
   catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
   }
	
   // delete[] Data;       
   return 0;
}
