#include <algorithm>
#include <cfloat>
#include <chrono>
#include <fstream>
#include <iostream>
#include <random>
#include <sstream>
#include <vector>
#include <boost/tokenizer.hpp>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>
#include <random>

#include "timer.h"

using namespace std;

std::vector < std::vector< std::string > > parse_csv(const char* filepath)
{
    std::vector< std::vector< std::string > > cells;
    std::string line;
    std::ifstream ifs(filepath);

    // csvを走査
    while (std::getline(ifs, line)) {

        std::vector< std::string > data;

        // 1行を走査
        boost::tokenizer< boost::escaped_list_separator< char > > tokens(line);
        for (const std::string& token : tokens) {
            data.push_back(token);
        }

        // 1行読み込んだ結果を入れる
        cells.push_back(data);
    }

    return cells;
}

int main(int argc, const char* argv[])
{
  int N = atoi(argv[2]);
  
  int counter = 0;
  int ngpus = 4;
  const size_t ullBytes = N * sizeof(unsigned long long);  
  const size_t lBytes = N * sizeof(long);  

  int RATIO = 100000;
  unsigned int t, travdirtime; 

  unsigned long long **d_A = (unsigned long long **)malloc(sizeof(unsigned long long *) * ngpus);
  long **d_B = (long **)malloc(sizeof(long *) * ngpus);
  
  unsigned long long *h_A;
  long *h_B;  

  h_A = (unsigned long long *)malloc(ullBytes);
  h_B = (long *)malloc(lBytes);

  cudaStream_t *stream = (cudaStream_t *)malloc(sizeof(cudaStream_t) * ngpus); 

  for (int i = 0; i < ngpus; i++)
  {
	cudaSetDevice(i);
        cudaMalloc((void **) &d_A[i], ullBytes);
	cudaMalloc((void **) &d_B[i], lBytes);
        cudaStreamCreate(&stream[i]);
  }

  const auto cells = parse_csv(argv[1]);

  counter = 0;
  for (const auto& rows : cells) {
      h_A[counter] = std::stoull(rows[0]);
      h_B[counter] = 1;

      if(counter % RATIO == 0)
      {
	cout << "stored " << counter / RATIO << "..." << endl;
      }

      counter = counter + 1;
  }

  thrust::host_vector<unsigned long long> h_key_in(N);
  thrust::host_vector<long> h_value_in(N);

  for(int i = 0; i < N; i++)
  {
      h_key_in[i] = h_A[i];
      h_value_in[i] = h_B[i];
  }

  cudaSetDevice(0);

  thrust::device_vector<unsigned long long> key_in_0(N); 
  thrust::device_vector<long> value_in_0(N); 

  thrust::device_vector<unsigned long long> key_in_1(N); 
  thrust::device_vector<long> value_in_1(N); 

  thrust::copy(h_key_in.begin(), h_key_in.end(), key_in_0.begin());
  thrust::copy(h_value_in.begin(), h_value_in.end(), value_in_0.begin());    

  thrust::device_vector<unsigned long long> dkey_out_0(h_key_in.size());
  thrust::device_vector<long> dvalue_out_0(h_value_in.size());

  thrust::sort(thrust::cuda::par.on(stream[0]), key_in_0.begin(), key_in_0.end());
  auto new_end_0 = thrust::reduce_by_key(thrust::cuda::par.on(stream[0]), key_in_0.begin(), key_in_0.end(),
       	       	 							value_in_0.begin(),
       	       	 				       			dkey_out_0.begin(),
									dvalue_out_0.begin());
									
  long new_size_0 = new_end_0.first - dkey_out_0.begin();

  const size_t ullBytes2 = new_size_0 * sizeof(unsigned long long);  
  const size_t lBytes2 = new_size_0 * sizeof(long);  

  unsigned long long *h_C;
  long *h_D;  

  h_C = (unsigned long long *)malloc(ullBytes2);
  h_D = (long *)malloc(lBytes2);

  for(int i = 0; i < new_size_0; i++)
  {
	h_C[i] = dkey_out_0[i];
	h_D[i] = dvalue_out_0[i];
  }

  unsigned long long **d_C = (unsigned long long **)malloc(sizeof(unsigned long long *) * ngpus);
  long **d_D = (long **)malloc(sizeof(long *) * ngpus);

  for (int i = 0; i < ngpus; i++)
  {
	cudaSetDevice(i);
        cudaMalloc((void **) &d_C[i], ullBytes2);
	cudaMalloc((void **) &d_D[i], lBytes2);
  }

  cudaMemcpy(d_C[0], h_C, ullBytes2, cudaMemcpyHostToDevice);
  cudaMemcpy(d_D[0], h_D, ullBytes2, cudaMemcpyHostToDevice);

  cudaDeviceEnablePeerAccess(0, 1);  

  cout << "[Device0][transfer] Device0 to Device1" << endl;
  start_timer(&t);
  cudaMemcpy(d_C[1], d_D[0], ullBytes2, cudaMemcpyDeviceToDevice);
  cudaMemcpy(d_D[1], d_D[0], lBytes2, cudaMemcpyDeviceToDevice);
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);

  cudaSetDevice(1);

  cout << "[Device1][store] array to device_vector" << endl;
  start_timer(&t);
  for(int i = 0; i < new_size_0; i++)
  {
	key_in_1[i] = d_C[1][i];
	value_in_1[i] = d_D[1][i];
  }
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);

}
