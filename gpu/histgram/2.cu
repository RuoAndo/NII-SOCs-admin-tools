#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <cuda_runtime.h>
#include <stdio.h>

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/reduce.h>
#include <thrust/functional.h>
#include <thrust/random.h>
#include <thrust/sequence.h>

#include "csv.hpp"
#include "timer.h"
using namespace std;

struct is_eq_zero {
    __host__ __device__ bool operator()(long a) const {
                return (a==0);
		}
};

int main(int argc, char **argv)
{
    int N = atoi(argv[2]);
    int INTVL = atoi(argv[3]);

    unsigned int t, travdirtime; 

    int dev = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);
    printf("%s starting reduction at ", argv[0]);
    printf("device %d: %s ", dev, deviceProp.name);
    cudaSetDevice(dev);

    unsigned long long start_time = 20190114000000000;

    thrust::host_vector<unsigned long long> h_timestamp(N);
    thrust::host_vector<long> h_sourceIP(N);

    thrust::host_vector<long> h_IP_to_match(N);
  
    const string csv_file = std::string(argv[1]); 
    vector<vector<string>> data; 

    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
     std::cout << "read ERROR" << std::endl;
     return 1;
    }

    for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 
      h_timestamp[row] = stoll(rec[0]);
      h_sourceIP[row] = stol(rec[1]);
      h_IP_to_match[row] = 2639437048;
    }

    // thrust::host_vector<long long> h_timestamp(N);
    thrust::host_vector<unsigned long long> h_out(N);
    thrust::host_vector<unsigned long long> h_out_2(N);
    
    for(int i=0; i < N; i++)
    {
	h_out[i] = (h_timestamp[i] - start_time) / INTVL;
    }

    for(int i=0; i < N; i++)
    {
	h_out_2[i] = (h_out[i] * INTVL) + start_time;
    }

    for(int i=0; i < 5; i++)
    	    std::cout << h_timestamp[i] << "," << h_out_2[i] << std::endl;

    thrust::device_vector<long long> d_timestamp(N);
    thrust::device_vector<long long> d_out(N);
    thrust::device_vector<long long> d_out_2(N);

    thrust::copy(h_timestamp.begin(), h_timestamp.end(), d_timestamp.begin());
    thrust::copy(h_out.begin(), h_out.end(), d_out.begin());
    thrust::copy(h_out_2.begin(), h_out_2.end(), d_out_2.begin());

    thrust::device_vector<long> d_IP_to_match(N);
    thrust::device_vector<long> d_sourceIP(N);

    thrust::copy(h_IP_to_match.begin(), h_IP_to_match.end(), d_IP_to_match.begin());
    thrust::copy(h_sourceIP.begin(), h_sourceIP.end(), d_sourceIP.begin());
    
    thrust::device_vector<unsigned long> dev_c(N);
    thrust::transform(begin(d_sourceIP), end(d_sourceIP), // dev_a for input
                      begin(d_IP_to_match),               // dev_b for input
		      begin(dev_c),                       // dev_c for output
		      [] __device__ (long x, long y) -> unsigned long { return x - y; });

    thrust::device_vector<long long> dev_c_2(N);
    thrust::copy(dev_c.begin(), dev_c.end(), dev_c_2.begin());

    thrust::sort_by_key(dev_c.begin(), dev_c.end(), d_sourceIP.begin());
    thrust::sort_by_key(dev_c_2.begin(), dev_c_2.end(), d_out_2.begin());

    for(int i=0; i < 10; i++)
    	    std::cout << dev_c[i] << "," << d_sourceIP[i] << "," << d_out_2[i] << std::endl;

    int N_count = thrust::count_if(dev_c.begin(), dev_c.end(), is_eq_zero());
    thrust::device_vector<long> d_b(N_count);
    thrust::copy_if(dev_c.begin(), dev_c.end(), d_b.begin(), is_eq_zero());
    std::cout << d_b.size() << std::endl;

    std::cout << endl;

    cout << "writing file..." << endl;
    std::remove("tmp");
    ofstream outputfile("tmp"); 
    for(int i=0; i < d_b.size(); i++)
    	    outputfile << dev_c[i] << "," << d_sourceIP[i] << "," << d_out_2[i] << std::endl;
    outputfile.close();

    /*
    cout << "writing file..." << endl;
    std::remove("tmp");
    ofstream outputfile("tmp"); 

    for(int i=0; i < N; i++)
    {
	if(dev_c[i] == 0)
		outputfile << d_out_2[i] << "," << d_sourceIP[i] << "," << d_IP_to_match[i] << "," << dev_c[i] << endl;
    }		      

    outputfile.close();
    */
    
    /*
    int N_count = thrust::count_if(dev_c.begin(), dev_c.end(), is_smaller_than());
    thrust::device_vector<long> d_b(N_count);
    thrust::copy_if(dev_c.begin(), dev_c.end(), d_b.begin(), is_smaller_than());
    std::cout << d_b.size() << std::endl;
    */

    /*
    size_t bytes = size * sizeof(unsigned long long);
    unsigned long long *d_tmp = NULL;

    cudaMalloc((unsigned long long **)&d_tmp, bytes);
    cudaMemcpy(d_tmp, h_tmp, bytes, cudaMemcpyHostToDevice);
    */

    /*
    cout << "writing file..." << endl;
    std::remove("tmp");
    ofstream outputfile("tmp"); 

    for(int i=0; i < N; i++)
    {
	d_out_2[i] = (d_out[i] * 5) + start_time;
	outputfile << d_out_2[i] <<"," << h_sourceIP[i] << std::endl;	
    }
    outputfile.close();
    */

    /*
    cout << "writing file..." << endl;
    std::remove("tmp");
    ofstream outputfile("tmp"); 

    start_timer(&t); 
    for(int i = 0; i < 10; i++)
        std::cout << h_idata[i] << "," << h_odata[i] << "," << h_odata_2[i] << std::endl;

    outputfile.close();

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    */

    // reset device
    //　cudaDeviceReset();

    return EXIT_SUCCESS;
}
