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
// typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

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

  thrust::host_vector<unsigned long long> h_vec_1(N);
  thrust::host_vector<unsigned long long> h_vec_2(N);   

  thrust::device_vector<unsigned long long> d_vec_1(N);
  thrust::device_vector<unsigned long long> d_vec_2(N);

  size_t nBytes = N * sizeof(unsigned long long);

  /*
  unsigned long long *h_A, *h_B, *hostRef, *gpuRef;
  h_A     = (unsigned long long *)malloc(nBytes);
  h_B     = (unsigned long long *)malloc(nBytes);
  hostRef = (unsigned long long *)malloc(nBytes);
  gpuRef  = (unsigned long long *)malloc(nBytes);
  */

  // Data = new MyString[N];
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

	    timestamp = rec[0];
	    std::string pair = rec[1];

	    h_vec_1[row] = stoull(rec[0].c_str());

	    /*
	    h_vec_1[row] = stoull(string(pair.c_str()));
	    h_vec_2[row] = 1; // atol(pair.c_str());
	    */

	    // h_A[row] = rec[0];

	  }

      	  thrust::copy(h_vec_1.begin(), h_vec_1.end(), d_vec_1.begin());
	  thrust::copy(h_vec_1.begin(), h_vec_1.end(), d_vec_2.begin());

	  for (int i = 0; i < N; i++) {
	      std::cout << h_vec_1[i] << std::endl;

	      unsigned long long f = h_vec_1[i];

	      auto ff = [=]  __device__ (unsigned long long x) {return x - f ;};
              thrust::transform(d_vec_1.begin(),d_vec_1.end(),d_vec_2.begin(),ff);

	      counter = 0;
	      for(int j = 0; j < N; j++) {
	      	      if (d_vec_2[j]==0) {
		      	     // std::cout << d_vec_1[i] << "," << f << "," << d_vec_2[j] << std::endl;
			     counter = counter + 1;
			     }
	      }
	      
	      // std::cout << d_vec_1[i] << "," << counter << std::endl;
	      mp[d_vec_1[i]] = counter; 
	  }

	  for(auto x : mp) {
          	   std::cout << x.first << "," << x.second << "\n";
	  }
	  
   }
   catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
   }
	
   // delete[] Data;       
   return 0;
}
