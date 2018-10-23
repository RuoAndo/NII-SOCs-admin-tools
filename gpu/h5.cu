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

  // int in_size=100;
  long in_size = 100000000;
  std::cout << "vector size:" << in_size << std::endl;

  thrust::host_vector<int> h_vec_1(in_size);
  // std::generate(h_vec_1.begin(), h_vec_1.end(), rand);
  thrust::host_vector<int> h_vec_2(in_size);

  for(int i=0;i<in_size;i++)
    	  h_vec_1[i]=rand()%10;

  for(int i=0;i<in_size;i++)
    	  h_vec_2[i]=1;
	  
  thrust::device_vector<int> key_in(in_size);
  thrust::device_vector<int> value_in(in_size);

  thrust::copy(h_vec_1.begin(), h_vec_1.end(), key_in.begin());
  thrust::copy(h_vec_2.begin(), h_vec_2.end(), value_in.begin());

  // create output buffer
  thrust::device_vector<long> key_out(in_size, 0);
  thrust::device_vector<long> value_out(in_size, 0);

  thrust::sort(key_in.begin(), key_in.end());

// do reduction operation
auto new_end = thrust::reduce_by_key(key_in.begin(),
                                     key_in.end(),
                                     value_in.begin(),
                                     key_out.begin(),
                                     value_out.begin());

  long new_size = new_end.first - key_out.begin();
  
  for(long i=0; i < new_size;i++)
  {
   std::cout << key_out[i] << ",";
  }
   std::cout << std::endl;

  for(long i=0; i < new_size;i++)
  {
   std::cout << value_out[i] << ","; // << std::endl;
  }
   std::cout << std::endl;

  return 0;
}
