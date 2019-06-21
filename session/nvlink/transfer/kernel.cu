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

void transfer(unsigned long long *key, long *value, unsigned long long *key_out, long *value_out, int kBytes, int vBytes, size_t data_size, int *new_size, int thread_id)
{
    // unsigned long long *d_A;
    // long *d_B;
    unsigned int t, travdirtime;

    thrust::host_vector<unsigned long long> h_vec_key(data_size);
    thrust::host_vector<unsigned long long> h_vec_value(data_size);

    for(int i=0; i < data_size; i++)
    {
	h_vec_key[i] = key[i];
	h_vec_value[i] = value[i];
    }

    start_timer(&t);
    
    cudaSetDevice(thread_id);
    
    thrust::device_vector<unsigned long long> d_vec_key(data_size);
    thrust::device_vector<long> d_vec_value(data_size);
    
    thrust::copy(h_vec_key.begin(), h_vec_key.end(), d_vec_key.begin());
    thrust::copy(h_vec_value.begin(), h_vec_value.end(), d_vec_value.begin());
    
    cout << "thread:" << thread_id << " - transfer done." << endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    /* reduction */
    start_timer(&t);
    
    thrust::sort_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin());

    thrust::device_vector<unsigned long long> d_vec_key_out(data_size);
    thrust::device_vector<long> d_vec_value_out(data_size);

    auto new_end = thrust::reduce_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin(),
       	       	 		       d_vec_key_out.begin(), d_vec_value_out.begin());

    int new_size_r = new_end.first - d_vec_key_out.begin();

    cout << "thread:" << thread_id << " - reduction done." << endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    for(int i = 0; i < 5; i++)
    {
	cout << "threadID:" << thread_id << "-" << d_vec_key_out[i] << "," << d_vec_value_out[i] << endl;
    }

    /*
    start_timer(&t);
    for(int i = 0; i < new_size; i++)
    {
	key_out[i] =  d_vec_key_out[i];
	value_out[i] =  d_vec_value_out[i];
    }

    cout << "thread:" << thread_id << " - transfer(rev) done with new_size " << new_size << endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    */

    start_timer(&t);
    thrust::host_vector<unsigned long long> h_vec_key_2(data_size);
    thrust::host_vector<long> h_vec_value_2(data_size);

    thrust::copy(d_vec_value_out.begin(),d_vec_value_out.end(),h_vec_value_2.begin());
    thrust::copy(d_vec_key_out.begin(),d_vec_key_out.end(),h_vec_key_2.begin());

    for(int i = 0; i < new_size_r; i++)
    {
    	key_out[i] =  h_vec_key_2[i];
	value_out[i] =  h_vec_value_2[i];
    }

    cout << "thread:" << thread_id << " - transfer(rev) done with new_size " << new_size_r << endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    (*new_size) = new_size_r;

    /*
    for(int i = 0; i < 5; i++)
    {
	cout << "threadID:" << thread_id << "-" << h_vec_key_2[i] << "," << h_vec_value_2[i] << endl;
    }
    */

    /*
    start_timer(&t);

    cudaSetDevice(thread_id);
    cudaMalloc((unsigned long long**)&d_A, kBytes);
    cudaMalloc((long**)&d_B, vBytes);
    cudaMemcpy(d_A, key, kBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, value, vBytes, cudaMemcpyHostToDevice);

    cout << "thread:" << thread_id << " - transfer done." << endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    */
}

void kernel(long *h_key, long *h_value_1, long *h_value_2, string filename, int size)
{
  int N = size;

  cout << "kernel" << endl;

  for(int i = 0; i < 5; i++)
  {
	cout << h_key[i] << "," << h_value_1[i] << endl;
  }

  thrust::host_vector<int> h_vec_1(N);
  std::generate(h_vec_1.begin(), h_vec_1.end(), rand); 

  thrust::device_vector<int> key_in(N);
  thrust::copy(h_vec_1.begin(), h_vec_1.end(), key_in.begin()); 

  thrust::host_vector<unsigned long long> h_vec_key_1(N);
  thrust::host_vector<unsigned long long> h_vec_key_2(N);

  thrust::host_vector<long> h_vec_value_1(N);
  thrust::host_vector<long> h_vec_value_2(N);

  cout << N << endl;

  for(int i=0; i < N; i++)
  {
	// cout << h_key[i] << endl;
	h_vec_key_1[i] = h_key[i];
	h_vec_key_2[i] = h_key[i];
	h_vec_value_1[i] = h_value_1[i];
	h_vec_value_2[i] = h_value_2[i];
  }

  /* 1 -> 3 */

  thrust::device_vector<unsigned long long> d_vec_key_1(N);
  thrust::device_vector<long> d_vec_value_1(N);
  thrust::copy(h_vec_key_1.begin(), h_vec_key_1.end(), d_vec_key_1.begin());
  thrust::copy(h_vec_value_1.begin(), h_vec_value_1.end(), d_vec_value_1.begin());

  // thrust::sort_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin(), thrust::greater<unsigned long long>());

  thrust::sort_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin());

  thrust::host_vector<unsigned long long> h_vec_key_3(N);
  thrust::host_vector<long> h_vec_value_3(N);

  thrust::copy(d_vec_value_1.begin(),d_vec_value_1.end(),h_vec_value_3.begin());
  thrust::copy(d_vec_key_1.begin(),d_vec_key_1.end(),h_vec_key_3.begin());

  /* 2 -> 4 */

  thrust::device_vector<unsigned long long> d_vec_key_2(N);
  thrust::device_vector<long> d_vec_value_2(N);
  thrust::copy(h_vec_key_2.begin(), h_vec_key_2.end(), d_vec_key_2.begin());
  thrust::copy(h_vec_value_2.begin(), h_vec_value_2.end(), d_vec_value_2.begin());

  // thrust::sort_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin(), thrust::greater<unsigned long long>());

  thrust::sort_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin());

  thrust::host_vector<unsigned long long> h_vec_key_4(N);
  thrust::host_vector<long> h_vec_value_4(N);

  thrust::copy(d_vec_value_2.begin(),d_vec_value_2.end(),h_vec_value_4.begin());
  thrust::copy(d_vec_key_2.begin(),d_vec_key_2.end(),h_vec_key_4.begin());

  cout << "1 -> 3" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_3[i] << "," << h_vec_value_3[i] << endl;
  }

  cout << "2 -> 4" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_4[i] << "," << h_vec_value_4[i] << endl;
  }

  thrust::device_vector<unsigned long long> d_vec_key_1_out(N);
  thrust::device_vector<long> d_vec_value_1_out(N);

  thrust::device_vector<unsigned long long> d_vec_key_2_out(N);
  thrust::device_vector<long> d_vec_value_2_out(N);

  auto new_end_1 = thrust::reduce_by_key(d_vec_key_1.begin(), d_vec_key_1.end(), d_vec_value_1.begin(),
       	       	 		       d_vec_key_1_out.begin(), d_vec_value_1_out.begin());

  int new_size_1 = new_end_1.first - d_vec_key_1_out.begin() + 1; 

  thrust::host_vector<unsigned long long> h_vec_key_3_out(N);
  thrust::host_vector<long> h_vec_value_3_out(N);

  thrust::copy(d_vec_value_1_out.begin(),d_vec_value_1_out.end(),h_vec_value_3_out.begin());
  thrust::copy(d_vec_key_1_out.begin(),d_vec_key_1_out.end(),h_vec_key_3_out.begin());

  auto new_end_2 = thrust::reduce_by_key(d_vec_key_2.begin(), d_vec_key_2.end(), d_vec_value_2.begin(),
       	       	 		       d_vec_key_2_out.begin(), d_vec_value_2_out.begin());      

  int new_size_2 = new_end_2.first - d_vec_key_2_out.begin();// + 1; 

  thrust::host_vector<unsigned long long> h_vec_key_4_out(N);
  thrust::host_vector<long> h_vec_value_4_out(N);

  thrust::copy(d_vec_value_2_out.begin(),d_vec_value_2_out.end(),h_vec_value_4_out.begin());
  thrust::copy(d_vec_key_2_out.begin(),d_vec_key_2_out.end(),h_vec_key_4_out.begin());

  cout << "1 -> 3" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_3_out[i] << "," << h_vec_value_3_out[i] << endl;
  }

  cout << "2 -> 4" << endl;
  for(int i = 0; i < 5; i++)
  {
	cout << h_vec_key_4_out[i] << "," << h_vec_value_4_out[i] << endl;
  }

  ofstream outputfile(filename);
    
  cout << "all" << endl;

  outputfile << "timestamp, counted, bytes" << endl;
  
  for(int i = 0; i < new_size_2; i++)
  {
	// cout << h_vec_key_3_out[i] << "," << h_vec_value_3_out[i] << "," << h_vec_value_4_out[i] << endl;

	/*
	if(h_vec_key_3_out[i] != 0)
		outputfile << h_vec_key_3_out[i] << "," << h_vec_value_3_out[i] << "," << h_vec_value_4_out[i] << endl;
	*/
	
	std::string timestamp = to_string(h_vec_key_3_out[i]);

	outputfile << timestamp.substr(0,4) << "-" << timestamp.substr(4,2) << "-" << timestamp.substr(6,2) << " "
	     	   << timestamp.substr(8,2) << ":" << timestamp.substr(10,2) << ":" << timestamp.substr(12,2)
	     	   << "." << timestamp.substr(14,3) << "," 
		   << h_vec_value_3_out[i] << "," << h_vec_value_4_out[i] << endl;
  }

  outputfile.close();
  
}


