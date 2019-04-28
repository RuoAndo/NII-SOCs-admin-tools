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
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>   

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"
#include "utility.h"

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/system/cuda/experimental/pinned_allocator.h>
#include <thrust/system/cuda/execution_policy.h>
#include <thrust/fill.h>
#include <thrust/sequence.h>
#include <thrust/for_each.h>

#include "csv.hpp"
#include "timer.h"

using namespace tbb;
using namespace std;

std::vector<string> timestamp;

#define min(a, b) (a < b ? a : b)

typedef long mytype;
typedef thrust::host_vector<mytype, thrust::cuda::experimental::pinned_allocator<mytype> > pinnedVector1;

typedef thrust::host_vector<mytype, thrust::cuda::experimental::pinned_allocator<mytype> > pinnedVector2;

#define TV1 1
#define TV2 2




int main(int argc, char** argv) {

    int N = atoi(argv[2]);
    unsigned int t, travdirtime; 

    cudaSetDevice(0);
    pinnedVector1 hi1(N);
    pinnedVector2 ho1(N);

    cudaSetDevice(1);
    pinnedVector1 hi2(N);
    pinnedVector2 ho2(N);

    const string csv_file = std::string(argv[1]); 
    vector<vector<string>> data; 

    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
       cout << "read ERROR" << endl;
       return 1;
       }

    long size=atoi(argv[2]);

    for (unsigned int row = 0; row < data.size(); row++) {
    	vector<string> rec = data[row];

	std::string tms = rec[0];
	std::string bytes = rec[20];

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

	for(size_t c = bytes.find_first_of("\""); c != string::npos; c = c = bytes.find_first_of("\"")){
	      bytes.erase(c,1);
	}

	hi1.push_back(stol(tms));
	hi2.push_back(stol(tms));

	ho1.push_back(stol(bytes));
	ho2.push_back(stol(bytes));
    }

    cudaSetDevice(0);
    thrust::device_vector<mytype> di1(N);
    thrust::device_vector<mytype> do1(N);

    cudaSetDevice(1);
    thrust::device_vector<mytype> di2(N);
    thrust::device_vector<mytype> do2(N);

    cudaSetDevice(0);
    thrust::fill(hi1.begin(), hi1.end(),  TV1);
    thrust::sequence(do1.begin(), do1.end());

    cudaSetDevice(1);
    thrust::fill(hi2.begin(), hi2.end(),  TV2);
    thrust::sequence(do2.begin(), do2.end());

    cudaStream_t s1, s2;
  
    cudaSetDevice(0);
    cudaStreamCreate(&s1);
    cudaSetDevice(1);
    cudaStreamCreate(&s2);

    start_timer(&t);
    cudaSetDevice(0);
    cudaMemcpyAsync(thrust::raw_pointer_cast(di1.data()), thrust::raw_pointer_cast(hi1.data()), di1.size()*sizeof(mytype), cudaMemcpyHostToDevice, s1);

    cudaMemcpyAsync(thrust::raw_pointer_cast(di2.data()), thrust::raw_pointer_cast(hi2.data()), di2.size()*sizeof(mytype), cudaMemcpyHostToDevice, s2);

    cudaDeviceSynchronize();

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    

}



