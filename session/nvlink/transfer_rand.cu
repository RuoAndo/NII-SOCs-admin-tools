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
#include <functional> //for std::function
#include <algorithm>  //for std::generate_n

#include "timer.h"

using namespace std;

std::vector < std::vector< std::string > > parse_csv(const char* filepath)
{
    std::vector< std::vector< std::string > > cells;
    std::string line;
    std::ifstream ifs(filepath);

    while (std::getline(ifs, line)) {

        std::vector< std::string > data;

        boost::tokenizer< boost::escaped_list_separator< char > > tokens(line);
        for (const std::string& token : tokens) {
            data.push_back(token);
        }

        cells.push_back(data);
    }

    return cells;
}

int main(int argc, const char* argv[])
{

  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<unsigned long long> randN(20190501000000000, 20190501235959000);
  
  int N = atoi(argv[1]);
  
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


  start_timer(&t);
  cout << "generating the random number " << N << "..." << endl;
  unsigned long long r;
  long r2;
  for (int i = 0; i < N; ++i) {    
      r = randN(mt);
      h_A[counter] = r;
      r = randN(mt);
      h_B[counter] = r2;
  }
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);  

  /*
  thrust::device_vector<unsigned long long> d_key_in_0(N,0);
  thrust::device_vector<long> d_value_in_0(N,0);

  thrust::device_vector<unsigned long long> d_key_in_1(N,0);
  thrust::device_vector<long> d_value_in_1(N,0);
  */

  cudaSetDevice(0);
  cudaDeviceEnablePeerAccess(0, 1);  

  cout << "[transfer CPU->GPU] Host(h_A, h_B) to Device0(d_A[0], d_B[0])" << endl;
  start_timer(&t);
  cudaMemcpy(d_A[0], h_A, ullBytes, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B[0], h_B, lBytes, cudaMemcpyHostToDevice);
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);  

  cudaSetDevice(0);

  cout << "[transfer GPU->GPU] GPU0(d_A[0],d_B[0]) -> GPU1(d_A[1],d_B[1])" << endl;
  start_timer(&t);
  cudaMemcpy(d_A[1], d_A[0], ullBytes, cudaMemcpyDeviceToDevice);
  cudaMemcpy(d_B[1], d_B[0], lBytes, cudaMemcpyDeviceToDevice);
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);  

  cudaSetDevice(1);
  cudaDeviceEnablePeerAccess(1, 2);  

  cout << "[transfer GPU->GPU] GPU1(d_A[1],d_B[1]) -> GPU2(d_A[2],d_B[2])" << endl;
  start_timer(&t);
  cudaMemcpy(d_A[2], d_A[1], ullBytes, cudaMemcpyDeviceToDevice);
  cudaMemcpy(d_B[2], d_B[1], lBytes, cudaMemcpyDeviceToDevice);
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);  

  /*
  start_timer(&t);
  cout << "[copy] Array to device_vector in device 0" << endl;
  for(int i = 0; i < N; i++)
  {
  	  d_key_in_0[i] = d_A[0][i];
	  d_value_in_0[i] = d_B[0][i];
  }
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);  
  */

  /*
  cudaSetDevice(1);

  cout << "[copy] Array to device_vector in device 1" << endl;
  start_timer(&t);
  for(int i = 0; i < N; i++)
  {
  	  d_key_in_1[i] = d_A[1][i];
	  d_value_in_1[i] = d_B[1][i];
  }
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);
  */

}
