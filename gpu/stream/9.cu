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

  thrust::host_vector<long> h_vec_1_0(N);
  thrust::host_vector<long> h_vec_2_0(N);

  thrust::host_vector<long> h_vec_1_1(N);
  thrust::host_vector<long> h_vec_2_1(N);
  thrust::host_vector<long> h_vec_1_2(N);
  thrust::host_vector<long> h_vec_2_2(N);   

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

	 std::remove("tmp0");
	 ofstream outputfile("tmp0");
	 
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

	    h_vec_1_0.push_back(std::atol(timestamp.c_str()));
	    h_vec_2_0.push_back(1);

	    h_vec_1_1.push_back(std::atol(timestamp.c_str()));
	    h_vec_2_1.push_back(1);
	    h_vec_1_2.push_back(std::atol(timestamp.c_str()));
	    h_vec_2_2.push_back(1);

	    /*
	    if(row<(N/2))
	    {
		h_vec_1_1.push_back(std::atol(timestamp.c_str()));
	    	h_vec_2_1.push_back(1);
	    }
	    else
	    {
		h_vec_1_2.push_back(std::atol(timestamp.c_str()));
	   	h_vec_2_2.push_back(1);
	    }
	    */
	    
	  }

	  tbb::tick_count mainStartTime = tbb::tick_count::now();
	  start_timer(&t); 
	  thrust::device_vector<long> key_in_0 = h_vec_1_0;
	  thrust::device_vector<long> value_in_0 = h_vec_2_0;

	  thrust::sort(key_in_0.begin(), key_in_0.end());
	  thrust::device_vector<long> dkey_out_0(N,0);
	  thrust::device_vector<long> dvalue_out_0(N,0);

	  auto new_end_0 = thrust::reduce_by_key(key_in_0.begin(),
					       key_in_0.end(),
					       value_in_0.begin(),
					       dkey_out_0.begin(),
	  				       dvalue_out_0.begin());

	  long new_size_0 = new_end_0.first - dkey_out_0.begin();

	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

	  for(long i=0; i <new_size_0; i++)
	    {
		outputfile << dkey_out_0[i] << "," << dvalue_out_0[i] << endl;
	    }

	  /* streams */

          // tbb::tick_count mainStartTime = tbb::tick_count::now();

	  /*
	  start_timer(&t); 
	  mainStartTime = tbb::tick_count::now();
	  cudaStream_t *stream = (cudaStream_t *)malloc(sizeof(cudaStream_t) * 2);

	  thrust::device_vector<long> key_in_1 = h_vec_1_1;
	  thrust::device_vector<long> value_in_1 = h_vec_2_1;
	  thrust::device_vector<long> key_in_2 = h_vec_1_2;
	  thrust::device_vector<long> value_in_2 = h_vec_2_2; 

	  for (int i = 0; i < 2; i++)
              	   cudaStreamCreate(&stream[i]);

	  thrust::sort(thrust::cuda::par.on(stream[0]), key_in_1.begin(), key_in_1.end());
	  thrust::sort(thrust::cuda::par.on(stream[1]), key_in_2.begin(), key_in_2.end());

	  for (int i = 0; i < 2; i++)
	           cudaStreamSynchronize(stream[i]);
 
	  for (int i = 0; i < 2; i++)
              	   cudaStreamDestroy(stream[i]);

	  thrust::device_vector<long> dkey_out_1(N,0);
	  thrust::device_vector<long> dvalue_out_1(N,0);
	  thrust::device_vector<long> dkey_out_2(N,0);
	  thrust::device_vector<long> dvalue_out_2(N,0);
	  
	  for (int i = 0; i < 2; i++)
              	   cudaStreamCreate(&stream[i]);
	  
	  auto new_end_1 = thrust::reduce_by_key(thrust::cuda::par.on(stream[0]), key_in_1.begin(),
					       key_in_1.end(),
					       value_in_1.begin(),
					       dkey_out_1.begin(),
	  				       dvalue_out_1.begin());

	  auto new_end_2 = thrust::reduce_by_key(thrust::cuda::par.on(stream[1]), key_in_2.begin(),
					       key_in_2.end(),
					       value_in_2.begin(),
					       dkey_out_2.begin(),
	  				       dvalue_out_2.begin());

	  for (int i = 0; i < 2; i++)
	           cudaStreamSynchronize(stream[i]);
 
	  for (int i = 0; i < 2; i++)
              	   cudaStreamDestroy(stream[i]);

	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

	  long new_size_1 = new_end_1.first - dkey_out_1.begin();
	  long new_size_2 = new_end_2.first - dkey_out_2.begin();

	  std::remove("tmp2");
	  ofstream outputfile2("tmp2");
	  for(long i=0; i <new_size_1; i++)
	    {
		outputfile2 << dkey_out_1[i] << "," << dvalue_out_2[i] << endl;
	    }
	  outputfile2.close();

	  std::remove("tmp3");
	  ofstream outputfile3("tmp3");
	  for(long i=0; i <new_size_2; i++)
	    {
		outputfile3 << dkey_out_2[i] << "," << dvalue_out_2[i] << endl;
	    }
	  outputfile3.close();
	  */
	}
	
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        delete[] Data;
        // utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
