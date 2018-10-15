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

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"
typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include "util.h"

using namespace tbb;
using namespace std;

static bool verbose = false;
static bool silent = false;

// const int size_factor = 2;
// typedef concurrent_hash_map<MyString,int> StringTable;
typedef concurrent_hash_map<MyString,std::vector<string>> StringTable;
std::vector<string> v_pair;
std::vector<string> v_count;
static MyString* Data;

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

  // int counter = 0;
  int N = atoi(argv[2]);  
  char* tmpchar;

  struct in_addr inaddr;
  char *some_addr;

    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        if ( silent ) verbose = false;

        Data = new MyString[N];

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

         thrust::host_vector<long> h_vec_sourceIP(data.size());
	 thrust::host_vector<int> h_vec_sourcePort(data.size());
	 thrust::host_vector<long> h_vec_destIP(data.size());
	 thrust::host_vector<int> h_vec_destPort(data.size());
	 thrust::host_vector<int> h_vec_count(data.size());

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string pair = rec[0] + "," + rec[1];

	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        

	    std::string srcIP = rec[0];
	    std::string destIP = rec[2];

	    std::string srcPort = rec[1];
	    std::string destPort = rec[3];

	    for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
	      srcIP.erase(c,1);
	    }

	    for(size_t c = destIP.find_first_of("\""); c != string::npos; c = c = destIP.find_first_of("\"")){
	      destIP.erase(c,1);
	    }

	    for(size_t c = srcPort.find_first_of("\""); c != string::npos; c = c = srcPort.find_first_of("\"")){
	      srcPort.erase(c,1);
	    }

	    for(size_t c = destPort.find_first_of("\""); c != string::npos; c = c = destPort.find_first_of("\"")){
	      destPort.erase(c,1);
	    }
	    
	    char del = '.';

	    std::string sourceIP;
	    //std::bitset<8> trans_srcIP;

	    for (const auto subStr : split_string_2(srcIP, del)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atoi(subStr.c_str());
	      std::bitset<8> trans_srcIP =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans_srcIP.to_string();
	      sourceIP = sourceIP + trans_string;
	    }
	    
	    std::string destinationIP;
	    
	    for (const auto subStr : split_string_2(destIP, del)) {
	      unsigned long ipaddr_dest;
	      ipaddr_dest = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_dest);
	      std::string trans_string = trans.to_string();
	      destinationIP = destinationIP + trans_string;
	    }

	    std::string sourcePort;
	    
	    for (const auto subStr : split_string_2(srcPort, del)) {
	      unsigned long port_src;
	      port_src = atoi(subStr.c_str());
	      std::bitset<16> trans =  std::bitset<16>(port_src);
	      std::string trans_string = trans.to_string();
	      sourcePort = sourcePort + trans_string;
	    }

	    std::string destinationPort;
	    
	    for (const auto subStr : split_string_2(destPort, del)) {
	      unsigned long port_dest;
	      port_dest = atoi(subStr.c_str());
	      std::bitset<16> trans =  std::bitset<16>(port_dest);
	      std::string trans_string = trans.to_string();
	      destinationPort = destinationPort + trans_string;
	    }

	    std::bitset<32> sourceIP_final(sourceIP);
	    unsigned int sourceIP_integer = sourceIP_final.to_ullong();

	    /*
	    struct in_addr inaddr = { htonl(sourceIP_integer) };
	    char *some_addr = inet_ntoa(inaddr);
	    string some_string = string(some_addr);
	    std::cout << srcIP << "," << sourceIP_final << "," << sourceIP_integer << "," << some_string << "," ;
	    */

	    h_vec_sourceIP[row] = sourceIP_integer;

	    std::bitset<16> sourcePort_final(sourcePort);
	    unsigned int sourcePort_integer = sourcePort_final.to_ullong();
	    // std::cout << srcPort << "," << sourcePort_final << "," << sourcePort_integer << ",";

	    h_vec_sourcePort[row] = sourcePort_integer;

	    std::bitset<32> destinationIP_final(destinationIP);
	    unsigned int destinationIP_integer = destinationIP_final.to_ullong();
	    // std::cout << destIP << "," << destinationIP_final << "," << destinationIP_integer << ",";

	    h_vec_destIP[row] = destinationIP_integer;

	    std::bitset<16> destinationPort_final(destinationPort);
	    unsigned int destinationPort_integer = destinationPort_final.to_ullong();
	    // std::cout << destPort << "," << destinationPort_final << "," << destinationPort_integer << endl;

	    h_vec_destPort[row] = destinationPort_integer;

	    h_vec_count[row] = atoi(rec[4].c_str());

	    Data[row] += cstr;	    
	    delete[] cstr; 
	  }

	  thrust::device_vector<int> d_vec_count_1 = h_vec_count;
	  thrust::device_vector<int> d_vec_count_2 = h_vec_count;
          thrust::device_vector<int> d_vec_count_3 = h_vec_count;
	  thrust::device_vector<int> d_vec_count_4 = h_vec_count;

          thrust::device_vector<int> d_vec_count = h_vec_count;
    	  thrust::device_vector<int> d_vec_sourceIP = h_vec_sourceIP;
	  thrust::device_vector<int> d_vec_sourcePort = h_vec_sourcePort;
          thrust::device_vector<int> d_vec_destIP = h_vec_destIP;
	  thrust::device_vector<int> d_vec_destPort = h_vec_destPort;

// thrust::sort_by_key(d_vec_2.begin(), d_vec_2.end(), d_vec_1.begin(), thrust::greater<int>());

	  thrust::sort_by_key(d_vec_count_1.begin(), d_vec_count_1.end(), d_vec_sourceIP.begin(),thrust::greater<int>());
	  thrust::sort_by_key(d_vec_count_2.begin(), d_vec_count_2.end(), d_vec_sourcePort.begin(),thrust::greater<int>());
          thrust::sort_by_key(d_vec_count_3.begin(), d_vec_count_3.end(), d_vec_destIP.begin(),thrust::greater<int>());
	  thrust::sort_by_key(d_vec_count_4.begin(), d_vec_count_4.end(), d_vec_destPort.begin(),thrust::greater<int>());

	  h_vec_count = d_vec_count_1;
	  h_vec_sourceIP = d_vec_sourceIP;
	  h_vec_sourcePort = d_vec_sourcePort;
	  h_vec_destIP = d_vec_destIP;
	  h_vec_destPort = d_vec_destPort;

          ofstream outputfile("tmp");  

          for(int i=0; i< h_vec_count.size(); i++)
	  {

	    inaddr = { htonl(h_vec_sourceIP[i]) };
	    some_addr = inet_ntoa(inaddr);
	    string sourceIP_string = string(some_addr);

	    /*
	    inaddr = { htonl(h_vec_sourcePort[i]) };
	    some_addr = inet_ntoa(inaddr);
	    string sourcePort_string = string(some_addr);
	    */
	    
	    inaddr = { htonl(h_vec_destIP[i]) };
	    some_addr = inet_ntoa(inaddr);
	    string destIP_string = string(some_addr);

	    /*
	    inaddr = { htonl(h_vec_destPort[i]) };
	    some_addr = inet_ntoa(inaddr);
	    string destPort_string = string(some_addr);
	    */

	    // std::cout << h_vec_count[i] << "," << sourceIP_string << "," << h_vec_sourcePort[i] << "," << destIP_string << "," << h_vec_destPort[i] << endl;

	    outputfile << h_vec_count[i] << "," << sourceIP_string << "," << h_vec_sourcePort[i] << "," << destIP_string << "," << h_vec_destPort[i] << endl;
	  }

	  outputfile.close();

	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        delete[] Data;
        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
