
#include <omp.h>
#include <stdio.h> 
#include <stdlib.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <time.h>
#include <sys/time.h>

#define DSIZE 20000

using namespace std;

int main(int argc, char *argv[])
{
    timeval t1, t2;
    int num_gpus = 2;   // number of CUDA GPUs

    printf("%s Starting...\n\n", argv[0]);

    // determine the number of CUDA capable GPUs
    // cudaGetDeviceCount(&num_gpus);

    if (num_gpus < 1)
    {
        printf("no CUDA capable devices were detected\n");
        return 1;
    }

    // display CPU and GPU configuration
    printf("number of host CPUs:\t%d\n", omp_get_num_procs());
    printf("number of CUDA devices:\t%d\n", num_gpus);

    for (int i = 0; i < num_gpus; i++)
    {
        cudaDeviceProp dprop;
        cudaGetDeviceProperties(&dprop, i);
        printf("   %d: %s\n", i, dprop.name);
    }

    printf("initialize data\n");


    // initialize data
    typedef thrust::device_vector<int> dvec;
    typedef dvec *p_dvec;
    std::vector<p_dvec> dvecs;

    for(unsigned int i = 0; i < num_gpus; i++) {
      cudaSetDevice(i);
      p_dvec temp = new dvec(DSIZE);
      dvecs.push_back(temp);
      }

    thrust::host_vector<int> data(DSIZE);
    thrust::generate(data.begin(), data.end(), rand);

    // copy data
    for (unsigned int i = 0; i < num_gpus; i++) {
      cudaSetDevice(i);
      thrust::copy(data.begin(), data.end(), (*(dvecs[i])).begin());
      }

    printf("start sort\n");
    gettimeofday(&t1,NULL);

    // run as many CPU threads as there are CUDA devices
    omp_set_num_threads(num_gpus);  // create as many CPU threads as there are CUDA devices
    #pragma omp parallel
    {
        unsigned int cpu_thread_id = omp_get_thread_num();
        cudaSetDevice(cpu_thread_id);
        thrust::sort((*(dvecs[cpu_thread_id])).begin(), (*(dvecs[cpu_thread_id])).end());
        cudaDeviceSynchronize();
    }
    gettimeofday(&t2,NULL);
    printf("finished\n");
    unsigned long et = ((t2.tv_sec * 1000000)+t2.tv_usec) - ((t1.tv_sec * 1000000) + t1.tv_usec);
    if (cudaSuccess != cudaGetLastError())
        printf("%s\n", cudaGetErrorString(cudaGetLastError()));
    printf("sort time = %fs\n", (float)et/(float)(1000000));
    // check results
    thrust::host_vector<int> result(DSIZE);
    thrust::sort(data.begin(), data.end());
    for (int i = 0; i < num_gpus; i++)
    {
        cudaSetDevice(i);
        thrust::copy((*(dvecs[i])).begin(), (*(dvecs[i])).end(), result.begin());
        for (int j = 0; j < DSIZE; j++)
          if (data[j] != result[j]) { printf("mismatch on device %d at index %d, host: %d, device: %d\n", i, j, data[j], result[j]); return 1;}
    }
    printf("Success\n");
    return 0;

}
