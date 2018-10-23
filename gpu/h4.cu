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

// input value
long key[in_size];
long value[in_size];

// const int key[]   {1, 1, 2, 2, 2, 3, 3, 1, 1};
// const int value[] {1, 1, 1, 1, 1, 1, 1, 1, 1};

for(long i=0;i<in_size;i++)
	key[i] = rand() % 8;

for(long i=0;i<in_size;i++)
	value[i] = 1;

// copy data from host to device
thrust::device_vector<long> key_in(key, key + in_size);
thrust::device_vector<long> value_in(value, value + in_size);

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
