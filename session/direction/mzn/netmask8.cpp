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
// #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"

using namespace std;

std::vector<string> sv;
std::vector<string> sourceIP;
std::vector<string> destinationIP;
std::vector<string> timestamp;

std::vector<string> IPstring_src;
std::vector<string> IPstring_dst;

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_timestamp_ingress;
static iTbb_timestamp_ingress TbbVec_timestamp_ingress; 

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_timestamp_egress;
static iTbb_timestamp_egress TbbVec_timestamp_egress; 

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
  int addr_counter = 0;
  
  int N = atoi(argv[3]);  
  int netmask;

  std::map <int,int> found_flag;
  std::map <int,int> found_flag_2;
  
    try {

	const string list_file = std::string(argv[1]); 
	vector<vector<string>> list_data; 
	
	const string session_file = std::string(argv[2]); 
	vector<vector<string>> session_data; 
	
	try {
	  Csv objCsv(list_file);
	  if (!objCsv.getCsv(list_data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }
	}
	catch (...) {
            cout << "EXCEPTION (session)" << endl;
	    return 1;
	}
  
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

	// init map
	  for(int i=0; i<N; i++)
	    {
	      found_flag[i] = 0;
	      found_flag_2[i] = 0;
	    }
	      
	  counter = 0;
	  for (unsigned int row = 0; row < list_data.size(); row++) {

	    vector<string> rec = list_data[row];
	    const string argIP = rec[0]; 
	    std::string argIPstring;

	    netmask = atoi(rec[1].c_str());
	    
	    std::cout << addr_counter << "(" << list_data.size() << "):" << argIP << "/" << netmask << std::endl;
	    
	    char del2 = '.';
	    
	    for (const auto subStr : split_string_2(argIP, del2)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atol(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      argIPstring = argIPstring + trans_string;
	    }
	    
	      for (unsigned int row2 = 0; row2 < session_data.size(); row2++) {
		vector<string> rec2 = session_data[row2];
		std::string srcIP = rec2[4];
		std::string destIP = rec2[7];

		for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
		  srcIP.erase(c,1);
		}

		for(size_t c = destIP.find_first_of("\""); c != string::npos; c = c = destIP.find_first_of("\"")){
		  destIP.erase(c,1);
		}
				
		std::string sessionIPstring;
		for (const auto subStr : split_string_2(srcIP, del2)) {
		  unsigned long ipaddr_src;
		  ipaddr_src = atol(subStr.c_str());
		  std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
		  std::string trans_string = trans.to_string();
		  sessionIPstring = sessionIPstring + trans_string;
		}
		
		std::bitset<32> bit_argIP(argIPstring);
		std::bitset<32> bit_sessionIP(sessionIPstring);
				
		std::bitset<32> trans2(0xFFFFFFFF);
		trans2 <<= netmask;
		bit_sessionIP &= trans2;
		
	        if(bit_sessionIP == bit_argIP)
		  {
		    std::string all_line;
		    all_line = "1";
		    for(auto itr = rec2.begin(); itr != rec2.end(); ++itr) {
		      all_line = all_line + "," + *itr;
		    }
		    found_flag[row2] = 1;
		  }

		std::string sessionIPstring_2;
		for (const auto subStr : split_string_2(destIP, del2)) {
		  unsigned long ipaddr_dest;
		  ipaddr_dest = atol(subStr.c_str());
		  std::bitset<8> trans =  std::bitset<8>(ipaddr_dest);
		  std::string trans_string = trans.to_string();
		  sessionIPstring_2 = sessionIPstring_2 + trans_string;
		}
		
		std::bitset<32> bit_argIP_2(argIPstring);
		std::bitset<32> bit_sessionIP_2(sessionIPstring_2);
				
		std::bitset<32> trans2_2(0xFFFFFFFF);
		trans2_2 <<= netmask;
		bit_sessionIP_2 &= trans2_2;
		
	        if(bit_sessionIP_2 == bit_argIP_2)
		  {
		    std::string all_line;
		    all_line = "0";
		    for(auto itr = rec2.begin(); itr != rec2.end(); ++itr) {
		      all_line = all_line + "," + *itr;
		    }
		    found_flag_2[row2] = 1;
		  }
	      }

	      addr_counter++;
	  }

	  int ingress_counter = 0;
	  int egress_counter = 0;
	  
	  for(auto itr = found_flag.begin(); itr != found_flag.end(); ++itr) {
	    if(itr->second==1)
	      ingress_counter++;
	  }

	  for(auto itr = found_flag_2.begin(); itr != found_flag_2.end(); ++itr) {
	    if(itr->second==1)
	      egress_counter++;
	  }
	      
	  std::cout << "INGRESS:" << ingress_counter << "," << "EGRESS:" << egress_counter << "," << "ALL:" << session_data.size() << std::endl;
	      
	  const string file_rendered_outward = session_file + "_egress";
	  ofstream outputfile_outward(file_rendered_outward);
	  
	  const string file_rendered_inward = session_file + "_ingress";
	  ofstream outputfile_inward(file_rendered_inward);
	  
	  for (unsigned int row3 = 0; row3 < session_data.size(); row3++) {
	    vector<string> rec3 = session_data[row3];
	    if(found_flag[row3]==1)
	      {
		std::string all_line;
		all_line = "1";
		for(auto itr = rec3.begin(); itr != rec3.end(); ++itr) {
		  all_line = all_line + "," + *itr;
		}
		outputfile_outward << all_line << std::endl;
	      }
	    if(found_flag_2[row3]==1)
	      {
		std::string all_line;
		all_line = "0";
		for(auto itr = rec3.begin(); itr != rec3.end(); ++itr) {
		  all_line = all_line + "," + *itr;
		}
		outputfile_inward << all_line << std::endl;
	      }	
	  }

	  outputfile_inward.close();
	  outputfile_outward.close();
	
        return 0;
    }
    
    catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
