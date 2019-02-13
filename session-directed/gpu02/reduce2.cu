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

int main( int argc, char* argv[] ) {

  int counter = 0;
  int N = atoi(argv[2]);  
  char* tmpchar;

  struct in_addr inaddr;
  char *some_addr;

  std::string timestamp;

  thrust::host_vector<unsigned long long> h_vec_1(N);
  thrust::host_vector<long> h_vec_2(N);   

  tbb::tick_count mainStartTime = tbb::tick_count::now();

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data)) {
     cout << "read ERROR" << endl;
     return 1;
     }

  for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row];
      timestamp = rec[0];
      h_vec_1[row] = stoull(timestamp.c_str());
      h_vec_2[row] = atol(rec[1].c_str());
      }

  thrust::device_vector<unsigned long long> key_in(N); // = h_vec_1;
  thrust::device_vector<unsigned long long> value_in(N); // = h_vec_2; 
  thrust::copy(h_vec_1.begin(), h_vec_1.end(), key_in.begin());
  thrust::copy(h_vec_2.begin(), h_vec_2.end(), value_in.begin());
  thrust::device_vector<unsigned long long> dkey_out(h_vec_1.size());
  thrust::device_vector<unsigned long long> dvalue_out(h_vec_2.size());

  thrust::sort(key_in.begin(), key_in.end()); 
  auto new_end = thrust::reduce_by_key(key_in.begin(),
					key_in.end(),
					value_in.begin(),
					dkey_out.begin(),
	  				dvalue_out.begin());

  long new_size = new_end.first - dkey_out.begin();
  cout << "size:" << key_in.size() << "," << new_size << endl;

  std::remove("tmp-final");
  ofstream outputfile2("tmp-final");  

  for(int i=0;i<new_size;i++)
  {
	// outputfile << dkey_out[i] << "," << dvalue_out[i] << std::endl;
	std::string tmpstring = std::to_string(dkey_out[i]);

	outputfile2 << tmpstring.substr( 0, 4 )
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
	<< "," << dvalue_out[i] << endl;
  }	  

  outputfile2.close();

  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());    
  return 0;

}
