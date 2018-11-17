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
#include "timer.h"

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

void sumArraysOnHost(float *A, float *B, float *C, const int N)
{
    for (int idx = 0; idx < N; idx++)
        C[idx] = A[idx] + B[idx];
}

__global__ void sumArraysOnGPU(float *A, float *B, float *C, const int N)
{
    // int i = blockIdx.x * blockDim.x + threadIdx.x;
     int i = blockIdx.x; // * blockDim.x + threadIdx.x;
    // C[i] = A[i] + B[i];
    C[i] = A[i] / B[i];
    // B[i] = B[i] + 1000;
    // C[i] = 3;
}

int main( int argc, char* argv[] ) {

  // int counter = 0;
  int N = atoi(argv[2]);  
  char* tmpchar;

  struct in_addr inaddr;
  char *some_addr;

  unsigned int t, travdirtime; 

    int dev = 0;
    cudaSetDevice(dev);
    int i;
    int counter;

    int nElem = N;
    printf("Vector size %d\n", nElem);

    size_t nBytes = nElem * sizeof(float);

    // float h_D[N];
    float *h_A, *h_B, *h_C, *h_D, *hostRef, *gpuRef;
    h_A     = (float *)malloc(nBytes);
    h_B     = (float *)malloc(nBytes);
    h_C     = (float *)malloc(nBytes);
    h_D     = (float *)malloc(nBytes);
    hostRef = (float *)malloc(nBytes);
    gpuRef  = (float *)malloc(nBytes);

    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        if ( silent ) verbose = false;

        Data = new MyString[N];

	const string csv_file = std::string(argv[1]); 
	vector<vector<string>> data; 

	const string targetIP = std::string(argv[3]); 

	std::string stringIP;
	std::string IPstring;

	char del2 = '.';

	for (const auto subStr : split_string_2(targetIP, del2)) {
	  unsigned long ipaddr_src;
	  ipaddr_src = atol(subStr.c_str());
	  std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	  std::string trans_string = trans.to_string();
	  IPstring = IPstring + trans_string;
	}
	
	unsigned long s = bitset<32>(IPstring).to_ulong();
        float f = (float)s;
	std::cout << f << endl;
	
	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

         thrust::host_vector<int> h_vec_1(N);

          counter = 0;
	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    std::string pair = rec[0] + "," + rec[1];
	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        

	    h_vec_1.push_back(atoi(rec[1].c_str()));
	    // std::cout << rec[1] << endl;
	    h_A[counter] = stof(rec[1]);
	    h_B[counter] = f;
	    h_C[counter] = 0;

	    Data[row] += cstr;	    
	    delete[] cstr;

	    counter = counter + 1;
	  }

    memset(hostRef, 0, nBytes);
    memset(gpuRef,  0, nBytes);

    float *d_A, *d_B, *d_C;
    cudaMalloc((float**)&d_A, nBytes);
    cudaMalloc((float**)&d_B, nBytes);
    cudaMalloc((float**)&d_C, nBytes);

    cudaMemcpy(d_A, h_A, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_C, gpuRef, nBytes, cudaMemcpyHostToDevice);

    dim3 block (1);
    dim3 grid  (N);

    start_timer(&t);  

    sumArraysOnGPU<<<grid, block>>>(d_A, d_B, d_C, nElem);
    printf("Execution configure <<<%d, %d>>>\n", grid.x, block.x);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    cudaMemcpy(h_D, d_C, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_C, d_C, nBytes, cudaMemcpyDeviceToHost);
    // cudaMemcpy(h_A, d_A, nBytes, cudaMemcpyDeviceToHost);

/*
    CHECK(cudaFree(d_A));
    CHECK(cudaFree(d_B));
    CHECK(cudaFree(d_C));
*/

    for(i=0;i<10;i++)
	printf("%f %f %f \n", h_A[i], h_B[i], h_D[i]);

    free(h_A);
    free(h_B);
    free(h_C);
    free(h_D);
    free(hostRef);
    free(gpuRef);

    cudaDeviceReset();

   

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
