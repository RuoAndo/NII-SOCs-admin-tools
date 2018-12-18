#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <pthread.h>

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <bitset>

#include <random>
#include <map>

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include "timer.h" 

#include <cstdio>
#include <cctype>
#include <iostream>
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"

using namespace tbb;
using namespace std;

#define THREAD_NUM 1

using namespace std;

struct HashCompare {
    static size_t hash( const char& x ) {
        return (size_t)x;
    }
    static bool equal( const char& x, const char& y ) {
        return x==y;
    }
};

typedef concurrent_hash_map<unsigned long, std::vector<unsigned long>> CharTable;
static CharTable table;

struct is_smaller_than_10 {
    __host__ __device__ bool operator()(const int a) const {
                return (a<1);
    }
};

typedef struct _thread_arg {
    int id;
} thread_arg_t;

typedef struct _result {
  map<long, long> m;
  pthread_mutex_t mutex;
} result_t;
result_t result;

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

void *thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int label = 0;
    unsigned int key = 0;
    unsigned int value = 0;
    int counter = 0;
    string src;
    string dst;
    int progress = 0;

    string fname;

    if(std::to_string(targ->id).length()==1)
        fname = "x0" + std::to_string(targ->id);

    if(std::to_string(targ->id).length()==2)
        fname = "x" + std::to_string(targ->id);
	
    std::cout << "thread ID: " << targ->id << " - start." << std::endl;

    ifstream ifs(fname);
 
    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;
      while(getline(stream,token,',')){
	
	if(counter==0)
	  src = token;

	if(counter==4)
	  dst = token;

        counter = counter + 1;
       }

	string tmp_string_first = src;
	string tmp_string_second = dst;

	for(size_t c = tmp_string_first.find_first_of("\""); c != string::npos; c = c = tmp_string_first.find_first_of("\"")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of(":"); c != string::npos; c = c = tmp_string_first.find_first_of(":")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of(" "); c != string::npos; c = c = tmp_string_first.find_first_of(" ")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of("/"); c != string::npos; c = c = tmp_string_first.find_first_of("/")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of("\""); c != string::npos; c = c = tmp_string_first.find_first_of("\"")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_first.find_first_of("."); c != string::npos; c = c = tmp_string_first.find_first_of(".")){
	      tmp_string_first.erase(c,1);
	}

	for(size_t c = tmp_string_second.find_first_of("\""); c != string::npos; c = c = tmp_string_second.find_first_of("\"")){
	      tmp_string_second.erase(c,1);
	}

	char del = '.';

	std::string stringIP;
	std::string IPstring;
	    	    
        stringIP = tmp_string_second;
	for (const auto subStr : split_string_2(stringIP, del)) {
	      unsigned long ipaddr_src;
	      ipaddr_src = atoi(subStr.c_str());
	      std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	      std::string trans_string = trans.to_string();
	      IPstring = IPstring + trans_string;
	}  

	unsigned long n = bitset<64>(IPstring).to_ullong();
	long m = atol(tmp_string_first.c_str());
	
	// cout << src << "," << n << "," << dst << "," << m << endl;

	CharTable::accessor a;
	table.insert(a, m);
	a->second.push_back(n);

	/*
	if(progress%100000==0)
	{
		cout <<  "progress count:" << targ->id << "," << progress << "," << table.size() << endl;
        }
	progress = progress + 1;
　　　　*/
    }

    std::cout << "thread ID: " << targ->id << " - done." << std::endl;
    return;
}

__global__ void sumArraysOnGPU(unsigned long *A, unsigned long *B, float *C, const int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    C[i] = A[i] % B[i];
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];

    string tmp_string_first;
    string tmp_string_second;

    unsigned int t, travdirtime;   
    int nData = atoi(argv[2]);
    int nBLK = atoi(argv[3]);
    int nGRD = atoi(argv[4]);

    int i;
    int counter;

    cout << "#1 concurrent hash map:" << endl;
    start_timer(&t);

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, thread_func, (void*)&targ[i]);
	// pthread_create(&handle[i], NULL, thread_func, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    thrust::host_vector<unsigned long> h_vec_1(nData);
    thrust::host_vector<unsigned long> h_vec_2(nData);

    cout << "#2 concurrent hash map to host_vector:" << endl; 
    start_timer(&t);

    counter = 0;
    for( CharTable::iterator i=table.begin(); i!=table.end(); ++i )
    {
      for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) {
	       h_vec_1[counter] = (unsigned long)(i->first);
   	       h_vec_2[counter] = (unsigned long)(*itr);
	       counter = counter + 1;
      }

      /*
      if(counter%1000000==0)
      {
	std::cout << "counter:" << counter << endl;
      }
      */
    }

    cout << "counter:" << counter << endl;

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    for(i=0; i<10; i++)
    {
	cout << h_vec_1[i] << "," << h_vec_2[i] << endl;
    }

    cout << "#3 host->GPU - sort by key:" << endl;

    start_timer(&t);

    thrust::device_vector<unsigned long> d_vec_1(h_vec_1.size()); // = h_vec_1;
    thrust::device_vector<unsigned long> d_vec_2(h_vec_2.size()); //  = h_vec_2;

    thrust::copy(h_vec_1.begin(), h_vec_1.end(), d_vec_1.begin());
    thrust::copy(h_vec_2.begin(), h_vec_2.end(), d_vec_2.begin());

    cout << "sort before:" << d_vec_2.size() << endl;
    thrust::sort_by_key(d_vec_1.begin(), d_vec_1.end(), d_vec_2.begin());
    cout << "sort after:" << d_vec_2.size() << endl;

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    for(i=0; i<10; i++)
    {
	cout << d_vec_1[i] << "," << d_vec_2[i] << endl;
    }      

    size_t nBytes = nData * sizeof(unsigned long);
    size_t iBytes = nData * sizeof(float);

    cout << "#4 GPU to host - ip to long - host to GPU" << endl;

    start_timer(&t);
    unsigned long *h_A, *h_B, *h_C, *hostRef, *gpuRef;
    float *h_D;
    h_A     = (unsigned long *)malloc(nBytes);
    h_B     = (unsigned long *)malloc(nBytes);
    h_C     = (unsigned long *)malloc(nBytes);
    h_D     = (float *)malloc(iBytes);
    hostRef = (unsigned long *)malloc(nBytes);
    gpuRef  = (unsigned long *)malloc(nBytes);

    cout << "allocated" << endl;

    const string targetIP = std::string(argv[1]); 

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
     unsigned long f = s;
     std::cout << targetIP << "," << f << endl;

    thrust::copy(d_vec_1.begin(), d_vec_1.end(), h_vec_1.begin());
    thrust::copy(d_vec_2.begin(), d_vec_2.end(), h_vec_2.begin());

     counter = 0;
     for(i=0;i<nData;i++)
     {	
    	h_A[i] = h_vec_1[i];
	h_B[i] = h_vec_2[i];
	h_C[i] = f;

        /*
	if(counter%10000000==0)
	  cout << "transfering " << counter << " vectors" << endl;
	*/
	counter = counter + 1;
    }

    cout << "done." << endl;

     for(i=0;i<10;i++)
     {	
    	cout << h_A[i] << "," << h_B[i] << "," << h_C[i] << endl;
    }

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    cout << "#5 transfer: host to GPU" << endl;

    start_timer(&t);  

    unsigned long *d_A, *d_B, *d_C;
    float *d_D;
    cudaMalloc((unsigned long**)&d_A, nBytes);
    cudaMalloc((unsigned long**)&d_B, nBytes);
    cudaMalloc((unsigned long**)&d_C, nBytes);
    cudaMalloc((float**)&d_D, iBytes);

    cudaMemcpy(d_A, h_A, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_C, h_C, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_D, h_D, iBytes, cudaMemcpyHostToDevice);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    cout << "#6 substraction:" << endl;
    
    start_timer(&t);  

    dim3 block=nBLK;
    dim3 grid=nGRD;

    sumArraysOnGPU<<<grid, block>>>(d_B, d_C, d_D, nData);
    printf("Execution configure <<<%d, %d>>>\n", grid.x, block.x);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    cudaMemcpy(h_A, d_A, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_B, d_B, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_C, d_C, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_D, d_D, iBytes, cudaMemcpyDeviceToHost);

    thrust::host_vector<float> h_vec_D(nData);
    thrust::host_vector<unsigned long> h_vec_A(nData);
    thrust::host_vector<unsigned long> h_vec_B(nData);
    thrust::host_vector<unsigned long> h_vec_C(nData);
    
    thrust::device_vector<float> d_vec_D(nData);
    thrust::device_vector<unsigned long> d_vec_A(nData);
    thrust::device_vector<unsigned long> d_vec_B(nData);
    thrust::device_vector<unsigned long> d_vec_C(nData);

    counter = 0;
     for(i=0;i<nData;i++)
     {
        h_vec_A[i] = h_A[i];
    	h_vec_D[i] = h_D[i];
	h_vec_B[i] = h_B[i];
	h_vec_C[i] = h_C[i];

	/*
	if(counter%10000==0)
	  cout << "transfering " << counter << " vectors" << endl;
	*/
	counter = counter + 1;
    }

    /*
    for(i=0;i<20;i++)
    	cout << h_vec_A[i] << "," << h_vec_B[i] << "," << h_vec_B[i] << "," << h_vec_D[i] << endl;
    */
    
    counter = 0;
    for(i=0;i<h_vec_D.size();i++)
    {
	if(h_vec_D[i]==0)
		counter = counter + 1;
    }

    cout << counter << endl;

    cout << "#3 host->GPU - sort by key:" << endl;

    start_timer(&t);

    thrust::copy(h_vec_A.begin(), h_vec_A.end(), d_vec_A.begin());
    thrust::copy(h_vec_D.begin(), h_vec_D.end(), d_vec_D.begin());

    cout << "sort before:" << d_vec_D.size() << endl;
    thrust::sort_by_key(d_vec_D.begin(), d_vec_D.end(), d_vec_A.begin());
    cout << "sort after:" << d_vec_D.size() << endl;

    /*
    for(i=0;i<20;i++)
    	cout << d_vec_D[i] << "," << d_vec_A[i] << endl;
   */
   
    std::cout << d_vec_D.size() << std::endl;
    int N_prime = thrust::count_if(d_vec_D.begin(), d_vec_D.end(), is_smaller_than_10());
    std::cout << N_prime << std::endl;
    thrust::device_vector<int> d_b(N_prime);
    thrust::copy_if(d_vec_D.begin(), d_vec_D.end(), d_b.begin(), is_smaller_than_10());
    std::cout << d_b.size() << std::endl;

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    /*
    for(i=0;i<d_b.size();i++)
    	cout << d_vec_A[i] << "," << d_vec_D[i] << endl;
    */
}
