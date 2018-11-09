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

std::vector<string> counts;
std::vector<string> counts_sent;
std::vector<string> counts_recv;
std::vector<string> bytes;
std::vector<string> bytes_sent;
std::vector<string> bytes_recv;

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

  struct in_addr inaddr;
  char *some_addr;
  
    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        // Data = new MyString[N];

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	std::remove("trans");
	ofstream outputfile("trans");
	
	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string srcIP = rec[4];
	    std::string destIP = rec[7];
	    std::string tms = rec[0];

	    for(size_t c = tms.find_first_of("\""); c != string::npos; c = c = tms.find_first_of("\"")){
	      tms.erase(c,1);
	    }

	    for(size_t c = tms.find_first_of("/"); c != string::npos; c = c = tms.find_first_of("/")){
	      tms.erase(c,1);
	    }

	    for(size_t c = tms.find_first_of("."); c != string::npos; c = c = tms.find_first_of(".")){
	      tms.erase(c,1);
	    }

	    for(size_t c = tms.find_first_of(" "); c != string::npos; c = c = tms.find_first_of(" ")){
	      tms.erase(c,1);
	    }

	    for(size_t c = tms.find_first_of(":"); c != string::npos; c = c = tms.find_first_of(":")){
	      tms.erase(c,1);
	    }
	    
	    for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
	      srcIP.erase(c,1);
	    }

	    for(size_t c = destIP.find_first_of("\""); c != string::npos; c = c = destIP.find_first_of("\"")){
	      destIP.erase(c,1);
	    }
	    
	    char del = '.';

	    std::string stringIP;
	    std::string IPstring;
	    	    
	    stringIP = srcIP;	    
	    for (const auto subStr : split_string_2(stringIP, del)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      IPstring = IPstring + trans_string;
	    }

	    IPstring_src.push_back(IPstring);
	    
	    stringIP = destIP;
	    for (const auto subStr : split_string_2(stringIP, del)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      IPstring = IPstring + trans_string;
	    }

	    IPstring_dst.push_back(IPstring.substr(32,32));
	    
	    sourceIP.push_back(srcIP);
	    destinationIP.push_back(destIP);
	    timestamp.push_back(tms);
	    
	    // string pair_string = stringIP;
	    // std:cout << IPstring << endl;
	    sv.push_back(IPstring);	    

	    for(size_t c = rec[17].find_first_of("\""); c != string::npos; c = c = rec[17].find_first_of("\"")){
	      rec[17].erase(c,1);
	    }

	    for(size_t c = rec[18].find_first_of("\""); c != string::npos; c = c = rec[18].find_first_of("\"")){
	      rec[18].erase(c,1);
	    }

	    for(size_t c = rec[19].find_first_of("\""); c != string::npos; c = c = rec[19].find_first_of("\"")){
	      rec[19].erase(c,1);
	    }

	    for(size_t c = rec[20].find_first_of("\""); c != string::npos; c = c = rec[20].find_first_of("\"")){
	      rec[20].erase(c,1);
	    }

	    for(size_t c = rec[21].find_first_of("\""); c != string::npos; c = c = rec[21].find_first_of("\"")){
	      rec[21].erase(c,1);
	    }

	    for(size_t c = rec[22].find_first_of("\""); c != string::npos; c = c = rec[22].find_first_of("\"")){
	      rec[22].erase(c,1);
	    }
	    
	    counts.push_back(rec[17]);
	    counts_sent.push_back(rec[18]);
	    counts_recv.push_back(rec[19]);
	    bytes.push_back(rec[20]);
	    bytes_sent.push_back(rec[21]);
	    bytes_recv.push_back(rec[22]);
	    
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}

	counter = 0;
	for(auto itr = sv.begin(); itr != sv.end(); ++itr) {
	     std::string tmp_string = *itr;
	     std::bitset<64> trans_tmp (tmp_string);
	     
	     long long int n = bitset<64>(tmp_string).to_ullong();
	     long long int s = bitset<32>(IPstring_src[counter]).to_ullong();
	     long long int d = bitset<32>(IPstring_dst[counter]).to_ullong();
	                                                                                    
             inaddr = { htonl(s) };
	     some_addr = inet_ntoa(inaddr);
	     string src_string = string(some_addr);

	     inaddr = { htonl(d) };
	     some_addr = inet_ntoa(inaddr);
	     string dst_string = string(some_addr);

	     // std::cout << srcIP << "," << destIP << "," << tmp_string << "," << n << endl;
	     // std::cout << timestamp[counter] << "," << sourceIP[counter] << "," << s << "," << src_string << "," << destinationIP[counter] << "," << d << "," << dst_string << "," << tmp_string << "," << n << endl;

	     outputfile << timestamp[counter] << "," << s << "," << d << "," << counts[counter] << "," << counts_sent[counter] << "," << counts_recv[counter] << "," << bytes[counter] << "," << bytes_sent[counter] << "," << bytes_recv[counter] << endl;
	     
	     // outputfile << timestamp[counter] << "," << n << endl;
	     counter = counter + 1;
	}

	outputfile.close();
	
        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
