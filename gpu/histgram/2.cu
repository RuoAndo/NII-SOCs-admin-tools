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

int main(int argc, char **argv)
{
    int N = atoi(argv[2]);
    int INTVL = atoi(argv[3]);

    unsigned int t, travdirtime; 

    int dev = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);
    printf("%s starting reduction at ", argv[0]);
    printf("device %d: %s \n", dev, deviceProp.name);
    cudaSetDevice(dev);

    unsigned long long start_time = 20190114000000000;

    if (argc < 4) {
            printf("Usage: ./2 file_name nLines span IP_address \n"); return 0;
    }      

    char del = '.';
    // std::string stringIP;
    std::string IPstring;

    std::string stringIP = argv[4];

    for (const auto subStr : split_string_2(stringIP, del)) {
    	unsigned long ipaddr_src;
	ipaddr_src = atoi(subStr.c_str());
	std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	std::string trans_string = trans.to_string();
	IPstring = IPstring + trans_string;
	}

    unsigned long long s = bitset<32>(IPstring).to_ullong();
    std::cout << "match:" << stringIP << "," << IPstring << "," << s << std::endl;

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

    /* hard coded */
    for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 
      h_timestamp[row] = stoll(rec[0]);
      h_sourceIP[row] = stol(rec[1]);
      // h_IP_to_match[row] = 2639437048;
      h_IP_to_match[row] = s;
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

    /* check */
    /*
    for(int i=0; i < 5; i++)
    	    std::cout << h_timestamp[i] << "," << h_out_2[i] << std::endl;
    */

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

    /* check */
    for(int i=0; i < 10; i++)
    	    std::cout << dev_c[i] << "," << d_sourceIP[i] << "," << d_out_2[i] << std::endl;

    int N_count = thrust::count_if(dev_c.begin(), dev_c.end(), is_eq_zero());
    thrust::device_vector<long> d_b(N_count);
    thrust::copy_if(dev_c.begin(), dev_c.end(), d_b.begin(), is_eq_zero());
    std::cout << d_b.size() << std::endl;

    std::cout << endl;

    thrust::device_vector<long long> d_timestamp_2(d_b.size());
    thrust::copy_n(thrust::device, d_out_2.begin(), d_b.size(), d_timestamp_2.begin());

    /*
    for(int i=0; i < d_b.size(); i++)
    	    std::cout << dev_c[i] << "," << d_timestamp_2[i] << std::endl;
    */

    thrust::device_vector<int> uni_vect(d_b.size(), 1); 

    thrust::device_vector<long long> dkey_out(d_b.size(),0);
    thrust::device_vector<int> dvalue_out(d_b.size(),0);

    thrust::sort(d_timestamp_2.begin(), d_timestamp_2.end());
    auto new_end = thrust::reduce_by_key(d_timestamp_2.begin(),d_timestamp_2.end(),uni_vect.begin(),
					 dkey_out.begin(),dvalue_out.begin());

    int new_size = new_end.first - dkey_out.begin();

    for(long i=0; i <10; i++)
    	     std::cout << dkey_out[i] << "," << dvalue_out[i] << endl;
	     
    /*
    cout << "writing file..." << endl;
    std::remove("tmp");
    ofstream outputfile("tmp"); 

    bitset<32> bs(d_sourceIP[0]);
    
    string bs1 = bs.to_string().substr(0,8);
    int bi1 =  bitset<8>(bs1).to_ulong();
    
    string bs2 = bs.to_string().substr(8,8);
    int bi2 =  bitset<8>(bs2).to_ulong();

    string bs3 = bs.to_string().substr(16,8);
    int bi3 =  bitset<8>(bs3).to_ulong();

    string bs4 = bs.to_string().substr(24,8);
    int bi4 =  bitset<8>(bs4).to_ulong();

    string sourceIP = to_string(bi1) + "." + to_string(bi2) + "." + to_string(bi3) + "." + to_string(bi4);

    for(int i=0; i < d_b.size(); i++)
       	    outputfile << sourceIP << "," << d_out_2[i] << std::endl;

    outputfile.close();
    */

    return EXIT_SUCCESS;
}
