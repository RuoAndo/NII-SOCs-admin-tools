#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include "util.h"

int main(void)
{
  // generate 32M random numbers serially
  thrust::host_vector<int> h_vec(1024 << 20);
  // thrust::host_vector<int> h_vec(1024 << 8);
  std::generate(h_vec.begin(), h_vec.end(), rand);

  static int counter;
  static int size;
  
  size = h_vec.size();

  std::cout << "size:" << size << std::endl;

  // transfer data to the device
  thrust::device_vector<int> d_vec = h_vec;

  // sort data on the device (846M keys per second on GeForce GTX 480)
  thrust::sort(d_vec.begin(), d_vec.end());

  cudaEvent_t     start, stop;
  HANDLE_ERROR( cudaEventCreate( &start ) );
  HANDLE_ERROR( cudaEventCreate( &stop ) );
  HANDLE_ERROR( cudaEventRecord( start, 0 ) );

  thrust::unique(d_vec.begin(),d_vec.end());

  HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
  HANDLE_ERROR( cudaEventSynchronize( stop ) );
  float   elapsedTime;
  HANDLE_ERROR( cudaEventElapsedTime( &elapsedTime, start, stop ) );
  printf( "Time to reorder array and points to the first repeated value:  %3.1f ms\n", elapsedTime );

  size = d_vec.size();

  std::cout << "size:" << size << std::endl;

  // transfer data back to host
  thrust::copy(d_vec.begin(), d_vec.end(), h_vec.begin());

  /*
  counter = 0;
  for(auto itr = h_vec.begin(); itr != h_vec.end(); ++itr)
  {
  	   if(counter % 10000==0)
	             std::cout << *itr << std::endl;

           counter = counter + 1;
  }
  */

  return 0;
}
