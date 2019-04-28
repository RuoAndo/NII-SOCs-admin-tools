#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/system/cuda/experimental/pinned_allocator.h>
#include <thrust/system/cuda/execution_policy.h>
#include <thrust/fill.h>
#include <thrust/sequence.h>
#include <thrust/for_each.h>
#include <iostream>
#include "timer.h"

// DSIZE determines duration of H2D and D2H transfers
#define DSIZE (1048576*64)
// SSIZE,LSIZE determine duration of kernel launched by thrust
#define SSIZE (512*512)
#define LSIZE 1
// KSIZE determines size of thrust kernels (number of threads per block)
#define KSIZE 64
#define TV1 1
#define TV2 2

typedef int mytype;
typedef thrust::host_vector<mytype, thrust::cuda::experimental::pinned_allocator<mytype> > pinnedVector;

struct sum_functor
{
  mytype *dptr;
  sum_functor(mytype* _dptr) : dptr(_dptr) {};
  __host__ __device__ void operator()(mytype &data) const
    {
      mytype result = data;
      for (int j = 0; j < LSIZE; j++)
        for (int i = 0; i < SSIZE; i++)
          result += dptr[i];
      data = result;
    }
};

int main(){

  unsigned int t, travdirtime; 

  cudaSetDevice(0);
  pinnedVector hi1(DSIZE);
  pinnedVector ho1(DSIZE);

  cudaSetDevice(1);
  pinnedVector hi2(DSIZE);
  pinnedVector ho2(DSIZE);

  cudaSetDevice(0);
  thrust::device_vector<mytype> di1(DSIZE);
  thrust::device_vector<mytype> do1(DSIZE);
  thrust::device_vector<mytype> dc1(KSIZE);

  cudaSetDevice(1);
  thrust::device_vector<mytype> di2(DSIZE);
  thrust::device_vector<mytype> do2(DSIZE);
  thrust::device_vector<mytype> dc2(KSIZE);

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
  thrust::for_each(thrust::cuda::par.on(s1), do1.begin(), do1.begin()+KSIZE, sum_functor(thrust::raw_pointer_cast(di1.data())));
  cudaMemcpyAsync(thrust::raw_pointer_cast(ho1.data()), thrust::raw_pointer_cast(do1.data()), do1.size()*sizeof(mytype), cudaMemcpyDeviceToHost, s1);
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);

  start_timer(&t); 
  cudaSetDevice(1);
  cudaMemcpyAsync(thrust::raw_pointer_cast(di2.data()), thrust::raw_pointer_cast(hi2.data()), di2.size()*sizeof(mytype), cudaMemcpyHostToDevice, s2);
  thrust::for_each(thrust::cuda::par.on(s2), do2.begin(), do2.begin()+KSIZE, sum_functor(thrust::raw_pointer_cast(di2.data())));
  cudaMemcpyAsync(thrust::raw_pointer_cast(ho2.data()), thrust::raw_pointer_cast(do2.data()), do2.size()*sizeof(mytype), cudaMemcpyDeviceToHost, s2);
  travdirtime = stop_timer(&t);
  print_timer(travdirtime);

  cudaDeviceSynchronize();


  for (int i=0; i < KSIZE; i++){
    if (ho1[i] != ((LSIZE*SSIZE*TV1) + i)) { std::cout << "mismatch on stream 1 at " << i << " was: " << ho1[i] << " should be: " << ((DSIZE*TV1)+i) << std::endl; return 1;}
    if (ho2[i] != ((LSIZE*SSIZE*TV2) + i)) { std::cout << "mismatch on stream 2 at " << i << " was: " << ho2[i] << " should be: " << ((DSIZE*TV2)+i) << std::endl; return 1;}
    }
  std::cout << "Success!" << std::endl;
  return 0;
}
