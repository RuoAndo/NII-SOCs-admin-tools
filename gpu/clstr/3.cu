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
  
  thrust::host_vector<float> h_vec_1(N);
  thrust::host_vector<float> h_vec_2(N);
  thrust::host_vector<float> h_vec_3(N);
  thrust::host_vector<float> h_vec_4(N);
  thrust::host_vector<float> h_vec_5(N);
  thrust::host_vector<float> h_vec_6(N);   

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data)) {
     cout << "read ERROR" << endl;
     return 1;
  }

  for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 

      h_vec_1[row] = std::stof(rec[0]);
      h_vec_2[row] = std::stof(rec[1]);
      h_vec_3[row] = std::stof(rec[2]);
      h_vec_4[row] = std::stof(rec[3]);
      h_vec_5[row] = std::stof(rec[4]);
      h_vec_6[row] = std::stof(rec[5]);
  }

  thrust::host_vector<float> d_vec_1(N);
  thrust::host_vector<float> d_vec_2(N);
  thrust::host_vector<float> d_vec_3(N);
  thrust::host_vector<float> d_vec_4(N);
  thrust::host_vector<float> d_vec_5(N);
  thrust::host_vector<float> d_vec_6(N);
      
  thrust::copy(h_vec_1.begin(), h_vec_1.end(), d_vec_1.begin());
  thrust::copy(h_vec_2.begin(), h_vec_2.end(), d_vec_2.begin());
  thrust::copy(h_vec_3.begin(), h_vec_3.end(), d_vec_3.begin());
  thrust::copy(h_vec_4.begin(), h_vec_4.end(), d_vec_4.begin());
  thrust::copy(h_vec_5.begin(), h_vec_5.end(), d_vec_5.begin());
  thrust::copy(h_vec_6.begin(), h_vec_6.end(), d_vec_6.begin());   

  float sum1 = thrust::reduce(d_vec_1.begin(), d_vec_1.end());
  float sum2 = thrust::reduce(d_vec_2.begin(), d_vec_2.end());
  float sum3 = thrust::reduce(d_vec_3.begin(), d_vec_3.end());
  float sum4 = thrust::reduce(d_vec_4.begin(), d_vec_4.end());
  float sum5 = thrust::reduce(d_vec_5.begin(), d_vec_5.end());
  float sum6 = thrust::reduce(d_vec_6.begin(), d_vec_6.end());

  std::cout << sum1 << std::endl;
  std::cout << sum2 << std::endl;
  std::cout << sum3 << std::endl;
  std::cout << sum4 << std::endl;
  std::cout << sum5 << std::endl;
  std::cout << sum6 << std::endl;

  return 0;
}
