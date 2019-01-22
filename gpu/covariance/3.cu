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

#include "Utilities.cuh"
#include "TimingGPU.cuh"

#include "csv.hpp"
using namespace std;

#define SAMPLE_RATIO 100

/********/
/* MAIN */
/********/
int main( int argc, char* argv[] )
{
  int N = atoi(argv[2]);
  
  thrust::host_vector<long> h_vec_1(N);
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

      h_vec_1.push_back(std::stof(rec[0].c_str()));
      h_vec_2[row] = std::stof(rec[1]);
  }

  thrust::host_vector<long> dout_2(N);
  thrust::host_vector<long> dout_3(N);
  thrust::host_vector<long> d_vec_2(N);
  
  thrust::copy(h_vec_2.begin(), h_vec_2.end(), d_vec_2.begin());   
  thrust::inclusive_scan(d_vec_2.begin(), d_vec_2.end(), dout_2.begin());
  thrust::exclusive_scan(d_vec_2.begin(), d_vec_2.end(), dout_3.begin());

  for(int i=0;i<N;i++)
  {
	// cout << d_vec_2[i] << "," << dout_2[i] << "," << dout_3[i] << endl;
	cout << d_vec_2[i] << "," << dout_3[i] << endl;
  }	  
  return 0;
}
