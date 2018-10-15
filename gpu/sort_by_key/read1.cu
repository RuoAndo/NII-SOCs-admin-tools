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

std::map<int, string> map_file1;
std::map<int, string> map_file2;

int main( int argc, char* argv[] ) {

  int counter = 0;
  int N = atoi(argv[3]);  
  // char* tmpchar;

  vector<string> file1;
  vector<string> file2;
  string concat_string;
  string file1_string;
  string file2_string;

  string key_string;
  string value_string;

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

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row];

	    /*
	    for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
	            std::cout<< *itr << "," ;
            }
	    */

	    concat_string = rec[1] + "," + rec[2] + "," + rec[3] + "," + rec[4];

	    map_file1[atoi(rec[0].c_str())] = concat_string;

	    // std::cout << concat_string << endl;
	    file1.push_back(concat_string);

	  }
	  
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}

        ///////

	const string csv_file_2 = std::string(argv[2]); 
	
	try {
	  Csv objCsv(csv_file_2);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row];

	    key_string = "";
	    value_string = "";
	    counter = 0;
	    for(auto itr = rec.begin(); itr != rec.end(); ++itr) {
	    	     if(counter > 5)
		       value_string = value_string + *itr + ",";
		     counter = counter + 1;
            }

	    map_file2[atoi(rec[4].c_str())] = value_string;

	    // std::cout << value_string << endl;
	    
	  }
	  
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}

	 std::map<int,string>::reverse_iterator i = map_file1.rbegin();

         ofstream outputfile("tmp2");  
   	 for( ; i != map_file1.rend() ; ++i )
	 {
     	     // std::cout << i->first << "," << i->second << "," << map_file2[i->first] << endl;
	     outputfile << i->first << "," << i->second << "," << map_file2[i->first] << endl;
	 }
	 outputfile.close();    

        delete[] Data;
        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
