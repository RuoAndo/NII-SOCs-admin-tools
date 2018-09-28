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
  // thrust::host_vector<int> h_vec(1024 << 20);
  thrust::host_vector<int> h_vec(1024 << 4);
  std::generate(h_vec.begin(), h_vec.end(), rand);

  static int i;
  static int size;
  
  size = h_vec.size();

  std::cout << "size:" << size << std::endl;

  // transfer data to the device
  thrust::device_vector<int> d_vec = h_vec;

  thrust::host_vector<int> h_vec_2(1024 << 4);

  for (i = 0; i < h_vec_2.size(); i++)
      h_vec_2[i] = i;

  thrust::device_vector<int> d_vec_2 = h_vec_2;

      /*
      const int N = 6;
      int    keys[N] = {  1,   4,   2,   8,   5,   7};
      char values[N] = {'a', 'b', 'c', 'd', 'e', 'f'};

      thrust::sort_by_key(keys, keys + N, values);
      */

      // thrust::device_vector<int> vec(13);
      
  thrust::device_vector<int>::iterator iter = d_vec_2.begin();

  thrust::sort_by_key(d_vec_2.begin(), d_vec_2.end(), d_vec.begin());
  				       		      
  // sort data on the device (846M keys per second on GeForce GTX 480)
  // thrust::sort(d_vec.begin(), d_vec.end());

  // for(auto itr=d_vec.begin(); itr!=d_vec.end(); itr++)
  //	   std::cout << *itr << std::endl;

  for(int i = 0; i < d_vec.size(); i++)
  	   std::cout << d_vec[i] << "," << d_vec_2[i] << std::endl;

  cudaEvent_t     start, stop;
  HANDLE_ERROR( cudaEventCreate( &start ) );
  HANDLE_ERROR( cudaEventCreate( &stop ) );
  HANDLE_ERROR( cudaEventRecord( start, 0 ) );

  return 0;
}
