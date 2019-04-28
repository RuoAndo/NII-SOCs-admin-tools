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

inline bool isCapableP2P(int ngpus)
{
    //cudaDeviceProp prop[ngpus];
    cudaDeviceProp *prop = (cudaDeviceProp *)malloc(ngpus * sizeof(cudaDeviceProp));

    int iCount = 0;

    for (int i = 0; i < ngpus; i++)
    {
        cudaGetDeviceProperties(&prop[i], i);

        if (prop[i].major >= 2) iCount++;

        printf("> GPU%d: %s %s capable of Peer-to-Peer access\n",
               i, prop[i].name, (prop[i].major >= 2 ? "is" : "not"));
    }

    if (iCount != ngpus)
    {
        printf("> no enough device to run this application\n");
    }

    return (iCount == ngpus);
}

/*
 * enable P2P memcopies between GPUs (all GPUs must be compute capability 2.0 or
 * later (Fermi or later)).
 */
inline void enableP2P(int ngpus)
{
    for (int i = 0; i < ngpus; i++)
    {
        cudaSetDevice(i);

        for (int j = 0; j < ngpus; j++)
        {
            if (i == j) continue;

            int peer_access_available = 0;
            cudaDeviceCanAccessPeer(&peer_access_available, i, j);

            if (peer_access_available)
            {
                cudaDeviceEnablePeerAccess(j, 0);
                printf("> GPU%d enabled direct access to GPU%d\n", i, j);
            }
            else
            {
                printf("(%d, %d)\n", i, j );
            }
        }
    }
}

inline void disableP2P(int ngpus)
{
    for (int i = 0; i < ngpus; i++)
    {
        cudaSetDevice(i);

        for (int j = 0; j < ngpus; j++)
        {
            if (i == j) continue;

            int peer_access_available = 0;
            cudaDeviceCanAccessPeer(&peer_access_available, i, j);

            if (peer_access_available)
            {
                cudaDeviceDisablePeerAccess(j);
                printf("> GPU%d disabled direct access to GPU%d\n", i, j);
            }
        }
    }
}

int main(int argc, char** argv) {

    int N = atoi(argv[2]);
    unsigned int t, travdirtime; 

    cudaSetDevice(0);
    pinnedVector1 hi1(N);
    pinnedVector2 ho1(N);

    cudaSetDevice(1);
    pinnedVector1 hi2(N);
    pinnedVector2 ho2(N);

    enableP2P(2);

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

    thrust::device_vector<mytype> dNVLNK(N);

    cudaSetDevice(0);
    thrust::fill(hi1.begin(), hi1.end(),  TV1);
    thrust::sequence(do1.begin(), do1.end());

    cudaSetDevice(1);
    thrust::fill(hi2.begin(), hi2.end(),  TV2);
    thrust::sequence(do2.begin(), do2.end());

    cudaStream_t s1, s2, s3;
  
    cudaSetDevice(0);
    cudaStreamCreate(&s1);
    
    cudaSetDevice(1);
    cudaStreamCreate(&s2);
    cudaStreamCreate(&s3);

    cout << "H1 -> D1: Host -> GPU0" << endl;
    start_timer(&t);
    cudaSetDevice(0);
    cudaMemcpyAsync(thrust::raw_pointer_cast(di1.data()), thrust::raw_pointer_cast(hi1.data()), di1.size()*sizeof(mytype), cudaMemcpyHostToDevice, s1);

    cout << "H2 -> D2: Host -> GPU1" << endl;
    cudaMemcpyAsync(thrust::raw_pointer_cast(di2.data()), thrust::raw_pointer_cast(hi2.data()), di2.size()*sizeof(mytype), cudaMemcpyHostToDevice, s2);

    cudaDeviceSynchronize();

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    cout << "D1-> GPU1: GPU0->GPU1" << endl;
    start_timer(&t);
    cudaSetDevice(0);
    cudaMemcpyAsync(thrust::raw_pointer_cast(dNVLNK.data()), thrust::raw_pointer_cast(di1.data()), dNVLNK.size()*sizeof(mytype), cudaMemcpyDeviceToDevice, s2);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
}



