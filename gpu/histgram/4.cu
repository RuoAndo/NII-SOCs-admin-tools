#include <cublas_v2.h>

#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/reduce.h>
#include <thrust/functional.h>
#include <thrust/random.h>
#include <thrust/sequence.h>

#include <stdio.h>
#include <iostream>

/*
#include "Utilities.cuh"
#include "TimingGPU.cuh"
*/

#include "csv.hpp"
using namespace std;

int main( int argc, char* argv[] )
{
  int N = atoi(argv[2]);
  
  thrust::host_vector<unsigned long long> h_vec_1(N);
  thrust::host_vector<long> h_vec_2(N);   

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data)) {
     cout << "read ERROR" << endl;
     return 1;
  }

  for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 
      std::string timestamp = rec[0];
      std::string bytes = rec[3];

      for(size_t c = timestamp.find_first_of("\""); c != string::npos; c = c = timestamp.find_first_of("\"")){
	  timestamp.erase(c,1);
	}

      for(size_t c = timestamp.find_first_of("\/"); c != string::npos; c = c = timestamp.find_first_of("\/")){
	  timestamp.erase(c,1);
	}

      for(size_t c = timestamp.find_first_of("\:"); c != string::npos; c = c = timestamp.find_first_of("\:")){
	  timestamp.erase(c,1);
	}

      for(size_t c = timestamp.find_first_of(" "); c != string::npos; c = c = timestamp.find_first_of(" ")){
	  timestamp.erase(c,1);
	}

      for(size_t c = timestamp.find_first_of("."); c != string::npos; c = c = timestamp.find_first_of(".")){
	  timestamp.erase(c,1);
	}

      for(size_t c = bytes.find_first_of("\""); c != string::npos; c = c = bytes.find_first_of("\"")){
	  bytes.erase(c,1);
	}

/*
      std::cout << timestamp << std::endl;
      std::cout << bytes << std::endl;
*/

      // h_vec_1.push_back(std::stoull(timestamp.c_str()));
      h_vec_1[row] = std::stoull(timestamp.c_str());
      h_vec_2[row] = std::stol(bytes);
  }

  int in_size = N;

  thrust::device_vector<unsigned long long> key_in(N);
  thrust::device_vector<long> value_in(N);

  /*
  thrust::device_vector<unsigned long long> key_in(in_size) = h_vec_1;
  thrust::device_vector<long> value_in(in_size) = h_vec_2;
  */

  thrust::copy(h_vec_1.begin(), h_vec_1.end(), key_in.begin());
  thrust::copy(h_vec_2.begin(), h_vec_2.end(), value_in.begin());

  thrust::device_vector<unsigned long long> key_out(in_size, 0);
  thrust::device_vector<long> value_out(in_size, 0);

  thrust::sort(key_in.begin(), key_in.end());

  auto new_end = thrust::reduce_by_key(key_in.begin(),
                                     key_in.end(),
                                     value_in.begin(),
                                     key_out.begin(),
                                     value_out.begin());

  long new_size = new_end.first - key_out.begin();
  
  for(long i=0; i < new_size;i++)
  {
   std::cout << key_out[i] << "," << value_out[i] << "," << std::endl;
  }
   std::cout << std::endl;

  return 0;
}
