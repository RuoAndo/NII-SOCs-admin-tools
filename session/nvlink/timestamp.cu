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
#include "timer.h"

using namespace tbb;
using namespace std;

std::vector<string> timestamp;

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

  int ngpus = 4;
  int RATIO = 1000000;
  const size_t iBytes = N * sizeof(float);  

  unsigned int t, travdirtime; 
  
  struct in_addr inaddr;
  char *some_addr;

    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);
        // Data = new MyString[N];

	float **d_A = (float **)malloc(sizeof(float *) * ngpus);
	float **d_B = (float **)malloc(sizeof(float *) * ngpus);
	float **d_C = (float **)malloc(sizeof(float *) * ngpus);

	float **h_A = (float **)malloc(sizeof(float *) * ngpus);
	float **h_B = (float **)malloc(sizeof(float *) * ngpus);    

	cudaStream_t *stream = (cudaStream_t *)malloc(sizeof(cudaStream_t) * ngpus); 

	for (int i = 0; i < ngpus; i++)
	  {
	    cudaSetDevice(i);
	    cudaMalloc((void **) &d_A[i], iBytes);
	    cudaMalloc((void **) &d_B[i], iBytes);
	    cudaMalloc((void **) &d_C[i], iBytes);

	    cudaMallocHost((void **) &h_A[i], iBytes);
	    cudaMallocHost((void **) &h_B[i], iBytes);

	    cudaStreamCreate(&stream[i]);
	  }                  

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	start_timer(&t);
	
	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
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

	    h_A[0][row] = stof(tms);

	    if(row % RATIO == 0)
	      {
		cout << "stored " << row / RATIO << "..." << endl; 
	      }
		  
	    // timestamp.push_back(tms);
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}

	travdirtime = stop_timer(&t);
	print_timer(travdirtime);  
	
	cudaSetDevice(0);
        cudaDeviceEnablePeerAccess(0, 1);
	
	start_timer(&t);
	cudaMemcpy(d_A[0], h_A[0], iBytes, cudaMemcpyHostToDevice);
	travdirtime = stop_timer(&t);
	print_timer(travdirtime);  

	start_timer(&t);
	cudaMemcpy(d_A[1], d_A[0], iBytes, cudaMemcpyDeviceToDevice);
	travdirtime = stop_timer(&t);
	print_timer(travdirtime);  
  
  
	/*
	std::remove("writethrough-timestamp");
	ofstream outputfile("writethrough-timestamp");
	
	for(auto itr = timestamp.begin(); itr != timestamp.end(); ++itr) {
	  outputfile  << *itr << std::endl;
	}
      
	outputfile.close();
	*/	


        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
