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

string now() {
    time_t t = time(0);
        char buffer[9] = {0};

    strftime(buffer, 9, "%H:%M:%S", localtime(&t));
    return string(buffer);
}

void discern(unsigned long *IPaddress, unsigned long *netmask, unsigned long address_to_match, double *result, size_t data_size, int thread_id)
{
    // int GPU_number = thread_id % 1;
    int GPU_number = 0;
    cudaSetDevice(GPU_number);

    struct timespec startTime, endTime, sleepTime;

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    // thrust::host_vector<double> IPaddress_hv(data_size);
    /*
    thrust::host_vector<double> netmask_hv(data_size);
    thrust::host_vector<double> masked_IPaddress_hv(data_size);
    thrust::host_vector<double> address_to_match_hv(data_size);
    thrust::host_vector<double> result_hv(data_size);
    */

    thrust::host_vector<double> IPaddress_hv(IPaddress, IPaddress + data_size);
    thrust::host_vector<double> netmask_hv(netmask, netmask + data_size);
    thrust::host_vector<double> result_hv(result, result + data_size);
    
    thrust::host_vector<double> address_to_match_hv(data_size);
    thrust::fill(address_to_match_hv.begin(), address_to_match_hv.end(), address_to_match);
    thrust::host_vector<double> masked_IPaddress_hv(data_size);
    thrust::fill(masked_IPaddress_hv.begin(), masked_IPaddress_hv.end(), 0);

    /*
    for(int i=0; i < data_size; i++)
    {
	IPaddress_hv[i] = (double)IPaddress[i];
	netmask_hv[i] = (double)netmask[i];
	masked_IPaddress_hv[i] = 0;
	address_to_match_hv[i] = (double)address_to_match;
	result_hv[i] = (double)result[i];
    }
    */

    clock_gettime(CLOCK_REALTIME, &endTime);
    printf("[insertion] ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec, endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    thrust::device_vector<double> IPaddress_dv = IPaddress_hv;
    thrust::device_vector<double> netmask_dv = netmask_hv;
    thrust::device_vector<double> masked_IPaddress_dv = masked_IPaddress_hv;
    thrust::device_vector<double> address_to_match_dv = address_to_match_hv;
    thrust::device_vector<double> result_dv = result_hv;

    clock_gettime(CLOCK_REALTIME, &endTime);
    printf("[tranfering] ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec, endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    thrust::transform(IPaddress_dv.begin(), IPaddress_dv.end(),
    		      netmask_dv.begin(), masked_IPaddress_dv.begin(),
		      thrust::bit_and<unsigned long>());
		      
    clock_gettime(CLOCK_REALTIME, &endTime);
    printf("[transform1] ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec, endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    // thrust::equal<double> op;

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    thrust::transform(masked_IPaddress_dv.begin(), masked_IPaddress_dv.end(),
    		      address_to_match_dv.begin(), result_dv.begin(),
		      thrust::minus<double>());
    clock_gettime(CLOCK_REALTIME, &endTime);
    printf("[transform2] ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec, endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");


    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    thrust::host_vector<double> result_hv_2(data_size);
    thrust::copy(result_dv.begin(), result_dv.end(),result_hv_2.begin());

    for(int i = 0; i < data_size; i++)
    {
    	result[i] =  result_hv_2[i];
    }

    clock_gettime(CLOCK_REALTIME, &endTime);
    printf("[transfer2] ");
    if (endTime.tv_nsec < startTime.tv_nsec) {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
       printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec, endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");
}

void sort(unsigned long long *key, long *value, unsigned long long *key_out, long *value_out, int kBytes, int vBytes, size_t data_size, int thread_id)
{
    // int GPU_number = thread_id % 1;
    int GPU_number = 0;
    // struct timespec startTime, endTime, sleepTime;
    cudaSetDevice(GPU_number);

    thrust::host_vector<unsigned long long> h_vec_key(data_size);
    thrust::host_vector<long> h_vec_value(data_size);

    for(int i=0; i < data_size; i++)
    {
	h_vec_key[i] = key[i];
	h_vec_value[i] = value[i];
    }
    
    thrust::device_vector<unsigned long long> d_vec_key(data_size);
    thrust::device_vector<long> d_vec_value(data_size);

    thrust::copy(h_vec_key.begin(), h_vec_key.end(), d_vec_key.begin());
    thrust::copy(h_vec_value.begin(), h_vec_value.end(), d_vec_value.begin());
    
    thrust::sort_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin());

    thrust::host_vector<unsigned long long> h_vec_key_2(data_size);
    thrust::host_vector<long> h_vec_value_2(data_size);

    thrust::copy(d_vec_value.begin(),d_vec_value.end(),h_vec_value_2.begin());
    thrust::copy(d_vec_key.begin(),d_vec_key.end(),h_vec_key_2.begin());
    
    for(int i = 0; i < data_size; i++)
    {
    	key_out[i] =  h_vec_key_2[i];
	value_out[i] =  h_vec_value_2[i];
    }
}

void transfer(unsigned long long *key, long *value, unsigned long long *key_out, long *value_out, int kBytes, int vBytes, size_t data_size, int *new_size, int thread_id)
{
    int GPU_number = thread_id % 4;
    //int GPU_number = 0;
    cudaSetDevice(GPU_number);

    struct timespec startTime, endTime, sleepTime;
    // struct timespec startTime, endTime;
    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    cout << "GPU" << GPU_number << ":thread_id" << thread_id << " - memory allocation start at: " << now() << endl;

    thrust::host_vector<unsigned long long> h_vec_key(data_size);
    thrust::host_vector<long> h_vec_value(data_size);

    for(int i=0; i < data_size; i++)
    {
	h_vec_key[i] = key[i];
	h_vec_value[i] = value[i];
    }

    thrust::device_vector<unsigned long long> d_vec_key(data_size);
    thrust::device_vector<long> d_vec_value(data_size);
    thrust::copy(h_vec_key.begin(), h_vec_key.end(), d_vec_key.begin());
    thrust::copy(h_vec_value.begin(), h_vec_value.end(), d_vec_value.begin());

    /*
    cudaStream_t stream;
    cudaStreamCreate(&stream);
    thrust::copy(thrust::cuda::par.on(stream), h_vec_key.begin(), h_vec_key.end(), d_vec_key.begin());
    thrust::copy(thrust::cuda::par.on(stream), h_vec_value.begin(), h_vec_value.end(), d_vec_value.begin());
    */

    cout << "GPU" << GPU_number << ":thread_id" << thread_id << " - memory allocation finished at: " << now() << endl;

    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
            printf("ThreadID:%d - [kernel][memory transfer hostToDevice] GPU[%d] - %ld.%ld", thread_id, GPU_number, 
	    			    	      			   endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      	    printf("ThreadID:%d - [kernel][memory transfer hostToDevice] GPU[%d] - %ld.%09ld ", thread_id, GPU_number,
	    			    	      			   	     	endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
	    // printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec \n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    thrust::sort_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin());
    thrust::device_vector<unsigned long long> d_vec_key_out(data_size);
    thrust::device_vector<long> d_vec_value_out(data_size);

    auto new_end = thrust::reduce_by_key(d_vec_key.begin(), d_vec_key.end(), d_vec_value.begin(), d_vec_key_out.begin(), d_vec_value_out.begin());
    int new_size_r = new_end.first - d_vec_key_out.begin();

    // thrust::sort_by_key(key, key + data_size, value);
    // auto new_end = thrust::reduce_by_key(key, key + data_size, value, key_out, value_out);

    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
            printf("ThreadID:%d - [kernel][reduction] GPU[%d] - %ld.%09ld", thread_id, GPU_number, 
	    						     		 endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      	    printf("ThreadID:%d - [kernel][reduction] GPU[%d] - %ld.%09ld ", thread_id, GPU_number, 
	    			    	      			         endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
	    					    		 
	    // printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec \n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    thrust::host_vector<unsigned long long> h_vec_key_2(data_size);
    thrust::host_vector<long> h_vec_value_2(data_size);

    thrust::copy(d_vec_value_out.begin(),d_vec_value_out.end(),h_vec_value_2.begin());
    thrust::copy(d_vec_key_out.begin(),d_vec_key_out.end(),h_vec_key_2.begin());

    for(int i = 0; i < new_size_r; i++)
    {
    	key_out[i] =  h_vec_key_2[i];
	value_out[i] =  h_vec_value_2[i];
    }

    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
            printf("ThreadID:%d - [kernel][memory transfer deviceToHost] GPU[%d] - %ld.%ld", thread_id, GPU_number,
	    			    	      			   endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      	    printf("ThreadID:%d - [kernel][memory transfer deviceToHost] GPU[%d] - %ld.%09ld ", thread_id, GPU_number,
	    			    	      			   	     	endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
	    // printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec \n");

    (*new_size) = new_size_r;
    // (*new_size) = sizeof(*new_end.first);

    // printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
    // printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
    // printf("経過実時間 = ");

    /*
    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
            printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      	    printf("GPU%d:thread_id:%d - [kernel][reduction] %ld.%09ld", GPU_number, thread_id,
	    			 endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
	    // printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec \n");
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


