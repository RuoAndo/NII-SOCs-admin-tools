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
  // generate random numbers serially
  thrust::host_vector<int> h_vec(1024 << 14);
  thrust::host_vector<int> h_vec_2(1024 << 14);
  std::generate(h_vec.begin(), h_vec.end(), rand);

  static int i;
  static int size;
  
  size = h_vec.size();

  std::cout << "size:" << size << std::endl;

  // transfer data to the device
  thrust::device_vector<int> d_vec = h_vec;

  for (i = 0; i < h_vec_2.size(); i++)
      h_vec_2[i] = i;

  thrust::device_vector<int> d_vec_2 = h_vec_2;
      
  // thrust::device_vector<int>::iterator iter = d_vec_2.begin();

  cudaEvent_t     start, stop;
  HANDLE_ERROR( cudaEventCreate( &start ) );
  HANDLE_ERROR( cudaEventCreate( &stop ) );
  
  HANDLE_ERROR( cudaEventRecord( start, 0 ) );

  thrust::sort_by_key(d_vec_2.begin(), d_vec_2.end(), d_vec.begin());
  
  HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
  HANDLE_ERROR( cudaEventSynchronize( stop ) );
  float   elapsedTime;
  HANDLE_ERROR( cudaEventElapsedTime( &elapsedTime, start, stop ) );
  printf( "Time to sort_by_key :  %3.1f ms\n", elapsedTime );

  /*
  for(int i = 0; i < d_vec.size(); i++)
  	   std::cout << d_vec[i] << "," << d_vec_2[i] << std::endl;
  */
 
  return 0;
}
