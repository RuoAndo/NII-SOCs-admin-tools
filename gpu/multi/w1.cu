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
#include "timer.h"

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
  unsigned int t, travdirtime; 

  int ngpus;
  // unsigned int t, travdirtime;

  printf("> starting %s", argv[0]);
  cudaGetDeviceCount(&ngpus);
  printf(" CUDA-capable devices: %i\n", ngpus);     

  thrust::host_vector<long> h_vec_1_0(N);
  thrust::host_vector<long> h_vec_2_0(N);

  thrust::host_vector<long> h_vec_1_1(N);
  thrust::host_vector<long> h_vec_2_1(N);
  thrust::host_vector<long> h_vec_1_2(N);
  thrust::host_vector<long> h_vec_2_2(N);   

  tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);
        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);
        if ( silent ) verbose = false;

        Data = new MyString[N];

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	  cout << "reading file..." << endl;
	  mainStartTime = tbb::tick_count::now();
	  start_timer(&t); 

	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  unsigned long long *timestamp_h;
          long *counted_h;    

    	  unsigned long long tBytes = data.size() * sizeof(unsigned long long);
	  long cBytes = data.size() * sizeof(long);   

	  timestamp_h = (unsigned long long *)malloc(tBytes);
	  counted_h = (long *)malloc(cBytes);  

	  unsigned long *timestamp_d;
	  long *counted_d;
	  
	  cudaMalloc((unsigned long long**)&timestamp_d, tBytes);
	  cudaMalloc((long**)&counted_d, cBytes);
	   
      	  for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string timestamp = rec[0];

	    for(size_t c = timestamp.find_first_of("\""); c != string::npos; c = c = timestamp.find_first_of("\"")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of("."); c != string::npos; c = c = timestamp.find_first_of(".")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of(" "); c != string::npos; c = c = timestamp.find_first_of(" ")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of(":"); c != string::npos; c = c = timestamp.find_first_of(":")){
	      timestamp.erase(c,1);
	    }
	    for(size_t c = timestamp.find_first_of("/"); c != string::npos; c = c = timestamp.find_first_of("/")){
	      timestamp.erase(c,1);
	    }

	    timestamp_h[row] = std::stoull(timestamp);
	    counted_h[row] = 1;
	    
	  }

	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

	  cout << "reading file..." << endl;
	  mainStartTime = tbb::tick_count::now();
	  start_timer(&t); 

	  cudaStream_t stream[2]; 

	  for (int i = 0; i < 2; ++i)
              {
	        cudaStreamCreate(&stream[i]);
          	}

          for (int i = 0; i < 2; ++i)
	      {
	    	cudaMemcpyAsync(&timestamp_d[data.size()], &timestamp_h[data.size()], tBytes,
						   cudaMemcpyHostToDevice, stream[i]);
              }	

	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

}
