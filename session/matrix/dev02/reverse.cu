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

    unsigned int t, travdirtime; 

    int dev = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);
    printf("%s starting reduction at ", argv[0]);
    printf("device %d: %s \n", dev, deviceProp.name);
    cudaSetDevice(dev);


    const string csv_file = std::string(argv[1]); 
    vector<vector<string>> data; 

    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
     std::cout << "read ERROR" << std::endl;
     return 1;
    }

    std::remove("tmp");
    ofstream outputfile("tmp"); 

    for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 

      std::string tmpstring = rec[0];

      char del = '.';
      std::string IPstring;
      std::string stringIP = rec[1];

      // std::cout << stringIP << endl;
      std::bitset<32> s = std::bitset<32>(stoull(stringIP));
      string bs = s.to_string();
      // std::cout << ss << endl;

      string bs1 = bs.substr(0,8);
      int bi1 =  bitset<8>(bs1).to_ulong();
    
      string bs2 = bs.substr(8,8);
      int bi2 =  bitset<8>(bs2).to_ulong();

      string bs3 = bs.substr(16,8);
      int bi3 =  bitset<8>(bs3).to_ulong();

      string bs4 = bs.substr(24,8);
      int bi4 =  bitset<8>(bs4).to_ulong();

      string sourceIP = to_string(bi1) + "." + to_string(bi2) + "." + to_string(bi3) + "." + to_string(bi4);
    
      outputfile << tmpstring.substr( 0, 4 )
	     	<< "-"
		<< tmpstring.substr( 4, 2 ) 
		<< "-"
		<< tmpstring.substr( 6, 2 )
		<< " "
		<< tmpstring.substr( 8, 2 )
		<< ":"
		<< tmpstring.substr( 10, 2 )
		<< ":"
		<< tmpstring.substr( 12, 2 )
		<< "\."
		<< tmpstring.substr( 14, 3 )
		<< "," << sourceIP << endl;      
    }

    outputfile.close();

    return EXIT_SUCCESS;
}
