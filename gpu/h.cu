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
  // thrust::host_vector<int> h_vec(1024 << 20);
  // std::generate(h_vec.begin(), h_vec.end(), rand);

  // static int counter;

  // transfer data to the device
  // thrust::device_vector<int> d_vec = h_vec;

  // sort data on the device (846M keys per second on GeForce GTX 480)
  // thrust::sort(d_vec.begin(), d_vec.end());


  // input value
  const int key[]   {1, 1, 2, 2, 2, 3, 3, 1, 1};
  const int value[] {1, 1, 1, 1, 1, 1, 1, 1, 1};

  // copy data from host to device
  thrust::device_vector<int> key_in(key, key + 9);
  thrust::device_vector<int> value_in(value, value + 9);

  // create output buffer
  thrust::device_vector<int> key_out(9);
  thrust::device_vector<int> value_out(9);

  // do reduction operation
  auto new_end = thrust::reduce_by_key(key_in.begin(),
                                     key_in.end(),
                                     value_in.begin(),
                                     key_out.begin(),
                                     value_out.begin());


  int new_size = new_end.first - key_out.begin() + 1;
  
  thrust::host_vector<int> hkey(new_size);
  thrust::host_vector<int> hvalue(new_size);

  // transfer data back to host
  thrust::copy(key_out.begin(), key_out.end(), hkey.begin());
  thrust::copy(value_out.begin(), value_out.end(), hvalue.begin());

  for(int i=0; i < hkey.size();i++)
  {
   std::cout << hkey[i] << ",";
  }
   std::cout << std::endl;

  for(int i=0; i < hvalue.size();i++)
  {
   std::cout << hvalue[i] << ","; // << std::endl;
  }
   std::cout << std::endl;

  // return 0;
}
