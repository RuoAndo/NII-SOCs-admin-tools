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
  
  // long key[N];
  // long value[N];   

  thrust::host_vector<long> h_vec_1(N);
  thrust::host_vector<long> h_vec_2(N);   

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

	 std::remove("tmp");
	 ofstream outputfile("tmp");

	 std::remove("raw");
	 ofstream outputfile2("raw");

	 outputfile << "timestamp, counted" << endl;

         for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 

	    h_vec_1.push_back(std::atol(rec[0].c_str()));
	    h_vec_2.push_back(std::atol(rec[1].c_str()));
	    
	    }

	    thrust::device_vector<long> key_in = h_vec_1;
	    thrust::device_vector<long> value_in = h_vec_2; 

	  // thrust::sort(key_in.begin(), key_in.end(),thrust::greater<int>());

	  thrust::sort(key_in.begin(), key_in.end());

	  thrust::device_vector<long> dkey_out(N,0);
	  thrust::device_vector<long> dvalue_out(N,0);
	  
	  auto new_end = thrust::reduce_by_key(key_in.begin(),
					       key_in.end(),
					       value_in.begin(),
					       dkey_out.begin(),
	  				       dvalue_out.begin());

	  long new_size = new_end.first - dkey_out.begin();
	  // std::cout << new_size << endl;
	  std::string tmpstring;

	  for(long i=0; i < new_size-1 ; i++)
	  {

	   if(std::to_string(dkey_out[i]).length()  == 17)
	   {
		tmpstring = std::to_string(dkey_out[i]);
					      
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
			   << "," << dvalue_out[i] << endl;

		outputfile2 << tmpstring << "," << dvalue_out[i] << endl;
	    }		      

	    }
	    
	  // std::cout << std::endl;
	  outputfile.close();
	  outputfile2.close();
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
