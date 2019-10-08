#if __linux__ && defined(__INTEL_COMPILER)
#define __sync_fetch_and_add(ptr,addend) _InterlockedExchangeAdd(const_cast<void*>(reinterpret_cast<volatile void*>(ptr)), addend)
#endif
#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>
#include <time.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>   

#include "utility.h"
#include "csv.hpp"

#include<thrust/host_vector.h>
#include<thrust/device_vector.h>
#include<thrust/sort.h>

using namespace std;

std::vector<string> sv;
std::vector<string> sourceIP;
std::vector<string> destinationIP;
std::vector<string> timestamp;

std::vector<string> IPstring_src;
std::vector<string> IPstring_dst;

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

int main( int argc, char* argv[] ) {

  int counter = 0;
  struct timespec startTime, endTime, sleepTime;

  int N = atoi(argv[2]);  
  int netmask;

  std::map <int,int> found_flag;
  const string session_file = std::string(argv[1]); 
  vector<vector<string>> session_data; 
	  
  try {
    Csv objCsv(session_file);
    if (!objCsv.getCsv(session_data)) {
      cout << "read ERROR" << endl;
      return 1;
    }
  }
  catch (...) {
    cout << "EXCEPTION (session)" << endl;
    return 1;
  }

  thrust::host_vector<unsigned long> V1(session_data.size());
  thrust::host_vector<unsigned long> V2(session_data.size());
  thrust::host_vector<unsigned long> V3(session_data.size());

  clock_gettime(CLOCK_REALTIME, &startTime);
  sleepTime.tv_sec = 0;
  sleepTime.tv_nsec = 123;

  for (unsigned int row2 = 0; row2 < session_data.size(); row2++) {
    vector<string> rec2 = session_data[row2];
    std::string srcIP = rec2[4];

    for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
      srcIP.erase(c,1);
    }

    char del2 ='.';
    std::string sessionIPstring;
    for (const auto subStr : split_string_2(srcIP, del2)) {
      unsigned long ipaddr_src;
      ipaddr_src = stoul(subStr.c_str());
      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
      std::string trans_string = trans.to_string();
      sessionIPstring = sessionIPstring + trans_string;
    }
    
    std::bitset<32> bit_sessionIP(sessionIPstring);
    std::bitset<32> bit_sessionIP_cuda(sessionIPstring);
    // cout << srcIP << "," << bit_sessionIP.to_ulong()  << endl;
    
    /* mask 1 */
    int netmask=24;    
    std::bitset<32> trans2(0xFFFFFFFF);
    trans2 <<= 32-netmask;
    // trans2 >>= netmask;
    bit_sessionIP &= trans2;

    std::string rev_string = bit_sessionIP.to_string();
    
    string bs1 = rev_string.substr(0,8);
    int bi1 =  bitset<8>(bs1).to_ulong();
    
    string bs2 = rev_string.substr(8,8);
    int bi2 =  bitset<8>(bs2).to_ulong();

    string bs3 = rev_string.substr(16,8);
    int bi3 =  bitset<8>(bs3).to_ulong();

    string bs4 = rev_string.substr(24,8);
    int bi4 =  bitset<8>(bs4).to_ulong();

    string revIP = to_string(bi1) + "." + to_string(bi2) + "." + to_string(bi3) + "." + to_string(bi4);

    if(row2 < 10)
    {
	cout << srcIP << "," << bit_sessionIP_cuda.to_ulong()  << "," << bit_sessionIP_cuda << "," << trans2 << "," << revIP << endl;
    }
  }

  clock_gettime(CLOCK_REALTIME, &endTime);

  if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1, endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
  } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec,endTime.tv_nsec - startTime.tv_nsec);
  }
  printf(" sec\n");

  clock_gettime(CLOCK_REALTIME, &startTime);
  sleepTime.tv_sec = 0;
  sleepTime.tv_nsec = 123;

  for (unsigned int row2 = 0; row2 < session_data.size(); row2++) {
    vector<string> rec2 = session_data[row2];
    std::string srcIP = rec2[4];

    for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
      srcIP.erase(c,1);
    }

    char del2 ='.';
    std::string sessionIPstring;
    for (const auto subStr : split_string_2(srcIP, del2)) {
      unsigned long ipaddr_src;
      ipaddr_src = stoul(subStr.c_str());
      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
      std::string trans_string = trans.to_string();
      sessionIPstring = sessionIPstring + trans_string;
    }
    
    std::bitset<32> bit_sessionIP_cuda(sessionIPstring);
    V1[row2] = bit_sessionIP_cuda.to_ulong();
  }

  netmask=24;    
  std::bitset<32> trans2(0xFFFFFFFF);
  // trans2 <<= netmask;
  trans2 <<= 32-netmask;
  
  thrust::fill(V2.begin(), V2.end(), trans2.to_ulong());

  thrust::device_vector<unsigned long> DV1 = V1;
  thrust::device_vector<unsigned long> DV2 = V2;
  thrust::device_vector<unsigned long> DV3 = V3;

  thrust::transform(DV1.begin(), DV1.end(), DV2.begin(), DV3.begin(), thrust::bit_and<unsigned long>());

  for(int i = 0; i < 10; i++)
  {
    std::bitset<32> bs1(DV1[i]);

    std::bitset<32> cuda_sessionIP(DV3[i]);
    std::string rev_string_2 = cuda_sessionIP.to_string();

    string rev1 = rev_string_2.substr(0,8);
    int bi1 =  bitset<8>(rev1).to_ulong();

    string rev2 = rev_string_2.substr(8,8);
    int bi2 =  bitset<8>(rev2).to_ulong();

    string rev3 = rev_string_2.substr(16,8);
    int bi3 =  bitset<8>(rev3).to_ulong();

    string rev4 = rev_string_2.substr(24,8);
    int bi4 =  bitset<8>(rev4).to_ulong();

    string revIP_2 = to_string(bi1) + "." + to_string(bi2) + "." + to_string(bi3) + "." + to_string(bi4);

    std::cout << DV1[i] << "," << bs1 << "," << DV2[i] << "," << trans2 << "," << DV3[i] << "," << revIP_2 << std::endl;
  }

  clock_gettime(CLOCK_REALTIME, &endTime);

  if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1, endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
  } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec,endTime.tv_nsec - startTime.tv_nsec);
  }
  printf(" sec\n");


}
