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

std::vector<std::string> split_string_2(std::string str, char del) {
  int first = 0;
  int last = str.find_first_of(del);

  std::vector<std::string> result;

  while (first < str.size()) {
    std::string subStr(str, first, last - first);

    result.push_back(subStr);

    first = last + 1;
    last = str.find_first_of(del, first);

    if (last == std::string::npos) {
      last = str.size();
    }
  }

  return result;
}

int main( int argc, char* argv[] ) {

    int N = atoi(argv[3]);  

    thrust::host_vector<long> h_vec_1_1(N);
    thrust::host_vector<long> h_vec_2_1(N);
    thrust::host_vector<long> h_vec_1_2(N);
    thrust::host_vector<long> h_vec_2_2(N);

    int ngpus;
    printf("> starting %s", argv[0]);

    cudaGetDeviceCount(&ngpus);
    printf(" CUDA-capable devices: %i\n", 2);
    cudaStream_t *stream = (cudaStream_t *)malloc(sizeof(cudaStream_t) * 2);
      
    vector<vector<string>> data;
    const string csv_file_1 = std::string(argv[1]);

    cout << "reading file 1..." << endl;
    Csv objCsv_1(csv_file_1);
    if (!objCsv_1.getCsv(data)) {
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

	h_vec_1_1[row] = std::atol(timestamp.c_str());
	h_vec_2_1[row] = 1;
	    
   }

   cout << "reading file 2..." << endl;
   const string csv_file_2 = std::string(argv[2]);
   Csv objCsv_2(csv_file_2);
   if (!objCsv_2.getCsv(data)) {
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

	    h_vec_1_2[row] = std::atol(timestamp.c_str());
	    h_vec_2_2[row] = 1;	    
   } 

   for(int i=0; i< 5; i++)
   {
	 cout << "h_vec_1_1" << "," << h_vec_1_1[i] << endl;
	 cout << "h_vec_1_2" << "," << h_vec_1_2[i] << endl;
   }

   cout << "creating stream..." << endl;
   for (int i = 0; i < 1; i++)
    	cudaStreamCreate(&stream[i]);

	/*
   thrust::device_vector<long> key_in_1 = h_vec_1_1;
   thrust::device_vector<long> value_in_1 = h_vec_2_1;

   thrust::device_vector<long> key_in_2 = h_vec_1_2;
   thrust::device_vector<long> value_in_2 = h_vec_2_2; 

   thrust::sort(thrust::cuda::par.on(stream[0]), key_in_1.begin(), key_in_1.end());
   thrust::sort(thrust::cuda::par.on(stream[1]), key_in_2.begin(), key_in_2.end());

   for(int i=0; i< 5; i++)
   {
	 cout << "key_in_1" << "," << key_in_1[i] << endl;
	 cout << "value_in_1" << "," << value_in_1[i] << endl;
   }

   cout << "sync 1" << endl;
	
   cudaStreamSynchronize(stream[0]);
   cudaStreamSynchronize(stream[1]);
   cudaStreamDestroy(stream[0]);
   cudaStreamDestroy(stream[1]);

   cout << "creating stream 2..." << endl;
   for (int i = 0; i < 2; i++)
    	cudaStreamCreate(&stream[i]);

   thrust::device_vector<long> dkey_out_1(N,0);
   thrust::device_vector<long> dvalue_out_1(N,0);
   thrust::device_vector<long> dkey_out_2(N,0);
   thrust::device_vector<long> dvalue_out_2(N,0);
	
   auto new_end_1 = thrust::reduce_by_key(thrust::cuda::par.on(stream[0]),
						key_in_1.begin(),
		    		             	key_in_1.end(),
					     	value_in_1.begin(),
					     	dkey_out_1.begin(),
	  				     	dvalue_out_1.begin());

   auto new_end_2 = thrust::reduce_by_key(thrust::cuda::par.on(stream[1]),
						key_in_2.begin(),
		    		             	key_in_2.end(),
					     	value_in_2.begin(),
					     	dkey_out_2.begin(),
	  				     	dvalue_out_2.begin());
   cudaStreamSynchronize(stream[0]);
   cudaStreamSynchronize(stream[1]);
   cudaStreamDestroy(stream[0]);
   cudaStreamDestroy(stream[1]);

   long new_size_1 = new_end_1.first - dkey_out_1.begin();
   long new_size_2 = new_end_2.first - dkey_out_2.begin();

   for(int i=0; i <5; i++)
   {
   	cout << dkey_out_1[i] << "," << dvalue_out_1[i] << endl;
   }

   for(int i=0; i <5; i++)
   {
	cout << dkey_out_2[i] << "," << dvalue_out_2[i] << endl;
   }
	*/

        return 0;	
}
