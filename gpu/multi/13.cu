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

	    /* sequential 0 */
	    h_vec_1_0.push_back(std::atol(timestamp.c_str()));
	    h_vec_2_0.push_back(1);
	    
	    if(row<(N/2))
	    {
		h_vec_1_1.push_back(std::atol(timestamp.c_str()));
	    	h_vec_2_1.push_back(1);
	    }
	    if(row>(N/2))
	    {
		h_vec_1_2.push_back(std::atol(timestamp.c_str()));
	   	h_vec_2_2.push_back(1);
	    }
	    
	  }

	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

	  cout << "sequential" << endl;
	  // tbb::tick_count mainStartTime = tbb::tick_count::now();
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

	  std::remove("tmp-sequential");
	  ofstream outputfile("tmp-sequential");

	  cout << "writing file.." << endl;
	  mainStartTime = tbb::tick_count::now();
	  start_timer(&t); 
	  for(long i=0; i <new_size_0; i++)
	    {
		outputfile << dkey_out_0[i] << "," << dvalue_out_0[i] << endl;
	    }

	  outputfile.close();

	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
	  
	  /* streams 1,2 */

	  cout << "streams" << endl;
	  start_timer(&t); 
	  mainStartTime = tbb::tick_count::now();
	  cudaStream_t *stream = (cudaStream_t *)malloc(sizeof(cudaStream_t) * 2);

	  for (int i = 0; i < 2; i++)
	  {
	      cudaSetDevice(i);
	      cudaStreamCreate(&stream[i]);
	  }
	
	  cudaSetDevice(0);
	  thrust::device_vector<long> key_in_1 = h_vec_1_1;
	  thrust::device_vector<long> value_in_1 = h_vec_2_1;
	  thrust::sort(thrust::cuda::par.on(stream[0]), key_in_1.begin(), key_in_1.end());

	  cudaSetDevice(1);
	  thrust::device_vector<long> key_in_2 = h_vec_1_2;
	  thrust::device_vector<long> value_in_2 = h_vec_2_2; 
	  thrust::sort(thrust::cuda::par.on(stream[1]), key_in_2.begin(), key_in_2.end());
	  
	  for (int i = 0; i < 2; i++)
	  {
	  	  cudaSetDevice(i);
	          cudaStreamSynchronize(stream[i]);
          }

	  for (int i = 0; i < 2; i++)
	  {
	  	  cudaSetDevice(i);
              	  cudaStreamDestroy(stream[i]);
          }
	  
	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
	  
	  for (int i = 0; i < 2; i++)
	  {
	  	 cudaSetDevice(i);
              	 cudaStreamCreate(&stream[i]);
          }

	  cudaSetDevice(0);
	  thrust::device_vector<long> dkey_out_1(N,0);
	  thrust::device_vector<long> dvalue_out_1(N,0);
	  auto new_end_1 = thrust::reduce_by_key(thrust::cuda::par.on(stream[0]), key_in_1.begin(),
					       key_in_1.end(),
					       value_in_1.begin(),
					       dkey_out_1.begin(),
	  				       dvalue_out_1.begin());
					       
	  cudaSetDevice(1);
	  thrust::device_vector<long> dkey_out_2(N,0);
	  thrust::device_vector<long> dvalue_out_2(N,0);
	  auto new_end_2 = thrust::reduce_by_key(thrust::cuda::par.on(stream[1]), key_in_2.begin(),
					       key_in_2.end(),
					       value_in_2.begin(),
					       dkey_out_2.begin(),
	  				       dvalue_out_2.begin());

	  for (int i = 0; i < 2; i++)
	  {
	  	   cudaSetDevice(i);
	           cudaStreamSynchronize(stream[i]);
          }

	  for (int i = 0; i < 2; i++)
	  {   
		   cudaSetDevice(i);
              	   cudaStreamDestroy(stream[i]);
          }

          /*
	  travdirtime = stop_timer(&t);
          print_timer(travdirtime); 
	  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
	  */

	  cudaSetDevice(0);
	  long new_size_1 = new_end_1.first - dkey_out_1.begin();

	  cudaSetDevice(1);
	  long new_size_2 = new_end_2.first - dkey_out_2.begin();

	  cudaSetDevice(0);
          thrust::host_vector<long> hkey_out_3(N,0);
	  thrust::host_vector<long> hvalue_out_3(N,0);

	  cudaSetDevice(0);
	  for(long i=0; i <new_size_1; i++)
	    {
		hkey_out_3.push_back(dkey_out_1[i]);
		hvalue_out_3.push_back(dvalue_out_1[i]);
	    }

	  cudaSetDevice(1);
	  for(long i=0; i <new_size_2; i++)
	    {
		hkey_out_3.push_back(dkey_out_2[i]);
		hvalue_out_3.push_back(dvalue_out_2[i]);
	    }

	  cudaSetDevice(0);
	  		
          thrust::device_vector<long> dkey_out_3 = hkey_out_3;
	  thrust::device_vector<long> dvalue_out_3 = hvalue_out_3;

	  thrust::device_vector<long> dkey_out_4(N,0);
	  thrust::device_vector<long> dvalue_out_4(N,0);

	  auto new_end_4= thrust::reduce_by_key(dkey_out_3.begin(),
					       dkey_out_3.end(),
					       dvalue_out_3.begin(),
					       dkey_out_4.begin(),
	  				       dvalue_out_4.begin());

	  long new_size_4 = new_end_4.first - dkey_out_4.begin();
	 
	  cout << "writing file..." << endl;

	  std::remove("tmp-streams");
	  ofstream outputfile2("tmp-streams");
	  
	  for(long i=0; i <new_size_1; i++)
	    {
		outputfile2 << dkey_out_1[i] << "," << dvalue_out_1[i] << endl;
	    }

	  for(long i=0; i <new_size_2; i++)
	    {
		outputfile2 << dkey_out_2[i] << "," << dvalue_out_2[i] << endl;
	    }

	  outputfile2.close();

}
