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

int main( int argc, char* argv[] ) {

  int N = atoi(argv[2]);  
  
  thrust::host_vector<unsigned long long> h_vec_1(N);
  thrust::host_vector<int> h_vec_2(N);   

    try {

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }
	 
      	  for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string timestamp = rec[0];

	    h_vec_1.push_back(std::stoull(timestamp));
	    h_vec_2.push_back(std::atoi(rec[1].c_str()));
	    }

	  thrust::device_vector<long> key_in = h_vec_1;
	  thrust::device_vector<long> value_in = h_vec_2; 

	  thrust::sort(key_in.begin(), key_in.end());

	  thrust::device_vector<long> dkey_out(N,0);
	  thrust::device_vector<long> dvalue_out(N,0);
	  
	  auto new_end = thrust::reduce_by_key(key_in.begin(),
					       key_in.end(),
					       value_in.begin(),
					       dkey_out.begin(),
	  				       dvalue_out.begin());

	  long new_size = new_end.first - dkey_out.begin();

	 std::remove("tmp");
	 ofstream outputfile("tmp");

	  for(long i=0; i <new_size; i++)
	    {
		if(std::to_string(dkey_out[i]).length()  == 17)
		{
			      // outputfile << dkey_out[i] << "," << dvalue_out[i] << endl;

			      std::string tmpstring = std::to_string(dkey_out[i]);
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
			      << "," << dvalue_out[i] << endl;
			      
	  	}
	    }

	  outputfile.close();
	}
	
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
