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
#include "utility.h"

#include "csv.hpp"
// typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

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

  int N = atoi(argv[2]);  
  unsigned int t, travdirtime; 
  // int counter;

  int ngpus;

  printf("> starting %s", argv[0]);
  cudaGetDeviceCount(&ngpus);
  printf(" CUDA-capable devices: %i\n", ngpus);     

  thrust::host_vector<long> h_vec_1_0(N);
  thrust::host_vector<long> h_vec_2_0(N);
  thrust::device_vector<long> d_vec_1_unique(N);

  tbb::tick_count mainStartTime = tbb::tick_count::now();

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  cout << "reading file...";
  mainStartTime = tbb::tick_count::now();

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data)) {
     cout << "read ERROR" << endl;
     return 1;
     }

  start_timer(&t); 
  mainStartTime = tbb::tick_count::now();
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

      // h_A[row] = std::atol(timestamp.c_str());

      if(row % 1000000 == 0)
      {
	utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
      }
    }

    cout << "done. # ";
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    
    mainStartTime = tbb::tick_count::now();
    thrust::device_vector<long> d_vec_1_0 = h_vec_1_0;
    // std::cout << h_vec_1_0.size() << endl;
    auto new_end_0 = thrust::unique(h_vec_1_0.begin(), h_vec_1_0.end());
    int new_size_0 = new_end_0 - h_vec_1_0.begin();
    std::cout << h_vec_1_0.size() << "->" << new_size_0 << endl;
    // std::cout << h_vec_1_0.size() << endl;
    std::cout << "unique # "; // << std::endl;
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

    mainStartTime = tbb::tick_count::now();
    size_t nBytes = new_size_0 * sizeof(long);
    long *d_A;
    cudaMalloc((long**)&d_A, nBytes);
    long *h_A;
    h_A = (long *)malloc(nBytes);

    for(int i = 0; i < new_size_0; i++)
    	    h_A[i] = h_vec_1_0[i];
    // cudaMemcpy(d_A, h_A, nBytes, cudaMemcpyHostToDevice);

    // int ngpus = 2;
    long **d_src = (long **)malloc(sizeof(long) * ngpus);
    long **d_rcv = (long **)malloc(sizeof(long) * ngpus);  

    for (int i = 0; i < ngpus; i++)
    {
	cudaSetDevice(i);
    	cudaMalloc(&d_src[i], nBytes);
    	cudaMalloc(&d_rcv[i], nBytes);
	cudaMemcpy(d_src[i], h_A, nBytes, cudaMemcpyHostToDevice);
    }
    std::cout << "GPU0: host_vector->device memory # "; // << std::endl;
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

    start_timer(&t); 
    mainStartTime = tbb::tick_count::now();
    cudaMemcpy(d_src[0], d_src[1], nBytes, cudaMemcpyDeviceToDevice);
    std::cout << "GPU0->GPU1: device memory -> device memory # "; // << std::endl;
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    mainStartTime = tbb::tick_count::now();
    cudaSetDevice(1);
    thrust::device_vector<long> d_vec_1(new_size_0);    

    for(int i = 0; i < new_size_0; i++)
    	    d_vec_1[i] = d_src[1][i];
    std::cout << "GPU1: device memory-> device vector # "; // << std::endl;
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

    // long *new_end = thrust::unique(h_A, h_A + N);
    // for( auto itr = new_end.begin(); itr < new_end.end(); itr++)

    mainStartTime = tbb::tick_count::now();
    cudaSetDevice(1);
    thrust::device_vector<long> d_vec_2(new_size_0);    
    for(int i = 0; i < new_size_0; i++)
    	    d_vec_2[i] = h_vec_1_0[i];
    std::cout << "GPU0->GPU1: host_vector -> device_vector # ";
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

    mainStartTime = tbb::tick_count::now();
    cudaSetDevice(1);
    // thrust::device_vector<long> d_vec_2(new_size_0);    
    for(int i = 0; i < new_size_0; i++)
    	    h_vec_1_0[i] = d_vec_2[i];
    std::cout << "GPU1: device_vector -> host_vector # ";
    utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

    // utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());

}
