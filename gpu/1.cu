#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>

int main(void)
{
  // generate 32M random numbers serially
  thrust::host_vector<int> h_vec(1024 << 20);
  std::generate(h_vec.begin(), h_vec.end(), rand);

  // static int counter;

  // transfer data to the device
  thrust::device_vector<int> d_vec = h_vec;

  // sort data on the device (846M keys per second on GeForce GTX 480)
  thrust::sort(d_vec.begin(), d_vec.end());

  // transfer data back to host
  thrust::copy(d_vec.begin(), d_vec.end(), h_vec.begin());

  /*
  counter = 0;
  for(auto itr = h_vec.begin(); itr != h_vec.end(); ++itr) {

  	   if(counter % 10000==0)
	             std::cout << *itr << std::endl;

           counter = counter + 1;
	   }
  */

  return 0;
}
