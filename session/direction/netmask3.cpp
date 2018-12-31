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
#include "tbb/concurrent_vector.h"
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"

using namespace tbb;
using namespace std;

concurrent_vector < string > IPpair;
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
  int N = atoi(argv[2]);  
  int netmask = atoi(argv[4]);
  
  struct in_addr inaddr;
  char *some_addr;
  
    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	// IP to convert
	const string argIP = std::string(argv[3]); 
       
	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {

	    vector<string> rec = data[row];

	    if(atoi(rec[0].c_str())==1)
	      {
		 std::string all_line;
	      	 for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
		   all_line = all_line + "," + *itr;
		 }
		 std::cout << all_line << std::endl;
		 break;
	      }
		   
	    // unsigned long long to string
	    std::string srcIP = rec[4];

	    unsigned long srcIP_long = std::atol(srcIP.c_str());

            inaddr = { htonl(srcIP_long) };
	    some_addr = inet_ntoa(inaddr);
	    string src_string = string(some_addr);

	    // string to bitset
	    
	    std::string stringIP;
	    std::string IPstring;

	    // converting argIP to bitset
	    
	    char del2 = '.';
	
	    for (const auto subStr : split_string_2(argIP, del2)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atol(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      IPstring = IPstring + trans_string;
	    }

	    // std::cout << endl;
	    // std::cout << "T:" << argIP << "/" << netmask << endl; 	

	    // argIP
	    unsigned long s = bitset<32>(IPstring).to_ullong();
	    // std::cout << "T:" << IPstring << endl;
	    // argIP (bitset) 
	    std::bitset<32> bs2(IPstring);
	    // std::cout << "T:" << bs2 << endl; 	

	    // address per line
	    // std::cout << "C:" << src_string << "/" << netmask << endl;
	    std::bitset<32> trans =  std::bitset<32>(srcIP_long);
	    // std::cout << "C:" << trans << endl;
	    
	    std::bitset<32> trans2(0xFFFFFFFF);
	    trans2 <<= netmask;
	    trans &= trans2;
	    // std::cout << "C:" << trans << std::endl; 

	    if(trans==bs2)
	      {
		std::string all_line;
		// all_line = "1";
		counter = 0;
		for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
		  if(counter==0)
		    all_line = rec[0];
		  else
		    all_line = all_line + "," + *itr;
		  counter = counter + 1;
		}
		std::cout << all_line << endl;
	      }
	    else
	      {
		std::string all_line;
		counter = 0;
		for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
		  if(counter==0)
		    all_line = rec[0];
		  else
		    all_line = all_line + "," + *itr;
		  counter = counter + 1;
		}
		std::cout << all_line << endl;
	      }
	    
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        // utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
