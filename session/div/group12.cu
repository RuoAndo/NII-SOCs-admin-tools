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

#define THREAD_NUM 50

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
                return (a==0);
    }
};

template<class T>
struct saxpi{
    T k1;
    T k2;
    saxpi(T _k1, T _k2){
        k1=_k1;
        k2=_k2;
    }
    __host__ __device__ T operator()(T &x) const{
        return x*k1+k2;
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

	unsigned long n = bitset<32>(IPstring).to_ullong();
	unsigned long m = atol(tmp_string_first.c_str());
	
	// cout << "CHECK:" << m << "," << n << ":" << endl;

	CharTable::accessor a;
	table.insert(a, m);
	a->second.push_back(n);

	if(progress%100000==0)
	{
		cout <<  "progress count:" << targ->id << "," << progress << "," << table.size() << endl;
        }
	progress = progress + 1;
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

    int i;
    int counter;

    cout << "#1 concurrent hash map:" << endl;
    start_timer(&t);

    /* ˆ—ŠJŽn */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, thread_func, (void*)&targ[i]);
	// pthread_create(&handle[i], NULL, thread_func, (void*)&targ[i]);
    }

    /* I—¹‚ð‘Ò‚Â */
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
	       h_vec_1[counter] = (unsigned long)i->first;
   	       h_vec_2[counter] = (unsigned long)*itr;
	      
      	       if(counter%1000000==0)
      	       {
	       std::cout << "counter:" << counter << endl;
	       std::cout << h_vec_1[counter] << "," << h_vec_2[counter] << endl;
	       std::cout << i->first << "," << *itr << endl;
      	       }
	       counter = counter + 1;
      }
    }

    cout << "counter:" << counter << endl;

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    for(i=0; i<counter; i++)
    {
	if(i%3000000==0)
	     cout << "CHECK:" << (unsigned long)h_vec_1[i] << "," << (unsigned long)h_vec_2[i] << endl;
    }

    /***/

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

    thrust::device_vector<unsigned long> d_vec_srcIP(nData);
    thrust::device_vector<unsigned long> d_vec_timestamp(nData);
    thrust::device_vector<int> d_vec_substract(nData);

    thrust::copy(h_vec_2.begin(), h_vec_2.end(), d_vec_srcIP.begin());
    thrust::copy(h_vec_1.begin(), h_vec_1.end(), d_vec_timestamp.begin());

    auto ff = [=]  __device__ (int x) {return x - f ;};
    thrust::transform(d_vec_srcIP.begin(),d_vec_srcIP.end(),d_vec_substract.begin(),ff);

    /*
    counter = 0;
    for(i=0; i<nData; i++)
    {
        if(d_vec_substract[i] == 0)
		cout << d_vec_timestamp[i] << "," << d_vec_srcIP[i] << "," << d_vec_substract[i] << endl;
		
	counter = counter + 1;
    }
    */

    cout << "#3 sort on GPU:" << endl;
    start_timer(&t);
    cout << "sort before:" << d_vec_timestamp.size() << endl;
    thrust::sort_by_key(d_vec_substract.begin(), d_vec_substract.end(), d_vec_timestamp.begin());
    cout << "sort after:" << d_vec_timestamp.size() << endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    cout << "#4 copy_if on GPU:" << endl;
    start_timer(&t);
    std::cout << d_vec_timestamp.size() << std::endl;
    int N_prime = thrust::count_if(d_vec_substract.begin(), d_vec_substract.end(), is_smaller_than_10());
    std::cout << N_prime << std::endl;
    thrust::device_vector<int> d_b(N_prime);
    thrust::copy_if(d_vec_substract.begin(), d_vec_substract.end(), d_b.begin(), is_smaller_than_10());
    std::cout << "d_b size:" << d_b.size() << std::endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);       

    thrust::host_vector<int> h_b(N_prime);
    thrust::host_vector<unsigned long> h_vec_timestamp(N_prime);

    for(i=0; i<N_prime; i++)
    {
	h_vec_timestamp[i] = d_vec_timestamp[i];
	h_b[i] = d_b[i];
    }

    std::remove("tmp");
    ofstream outputfile("tmp");

    for(i=0; i<N_prime; i++)
    {
	cout << h_vec_timestamp[i] << "," << h_b[i] << endl;

	std::string tmpstring = std::to_string(h_vec_timestamp[i]);
	outputfile << tmpstring.substr( 0, 4 ) << "-" << tmpstring.substr( 4, 2 ) << "-" << tmpstring.substr( 6, 2 ) << " " << tmpstring.substr( 8, 2) << ":" << tmpstring.substr( 10, 2 ) << ":" << tmpstring.substr( 12, 2 ) << "," << argv[1] << endl;;                  
    }

    outputfile.close();

    /*
    for(i=0; i<d_b.size(); i++)
    {
	cout << d_vec_timestamp[i] << "," << d_b[i] << endl;
    }
    */

}

