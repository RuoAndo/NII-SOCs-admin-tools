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
  int N = 1024 << 8;

  // generate 32M random numbers serially
  thrust::host_vector<int> h_vec_1(N);
  std::generate(h_vec_1.begin(), h_vec_1.end(), rand);

  thrust::host_vector<int> h_vec_2(N);
  std::generate(h_vec_2.begin(), h_vec_2.end(), rand);

  // static int counter;

  // transfer data to the device
  // thrust::device_vector<int> d_vec = h_vec;

  // sort data on the device (846M keys per second on GeForce GTX 480)
  // thrust::sort(d_vec.begin(), d_vec.end());

  // input value
  // const int key[]   {1, 1, 2, 2, 2, 3, 3, 1, 1};
  // const int value[] {1, 1, 1, 1, 1, 1, 1, 1, 1};

  // copy data from host to device
  // thrust::device_vector<int> key_in = h_vec_1;
  // thrust::device_vector<int> value_in(N,1);

  thrust::device_vector<int> key_in(N);
  thrust::device_vector<int> value_in(N,1);

  thrust::copy(h_vec_1.begin(), h_vec_1.end(), key_in.begin());
  // thrust::copy(h_vec_2.begin(), h_vec_2.end(), value_in.begin());

  // create output buffer
  thrust::device_vector<int> key_out(N);
  thrust::device_vector<int> value_out(N);

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

  for(int i=0; i < 10;i++)
  {
   std::cout << hkey[i] << ",";
  }
   std::cout << std::endl;

  for(int i=0; i < 10;i++)
  {
   std::cout << hvalue[i] << ","; // << std::endl;
  }
   std::cout << std::endl;

  thrust::sort(key_in.begin(), key_in.end());

  thrust::device_vector<int> uni_vect(N, 1); // 要素が全て1のベクトル
  thrust::device_vector<int> num_in_bins(N); // 各keyに所属している要素の数を入れるためのbuffer

  // thrust::device_vector<int> key_out_2(N);

  // do reduction operation
  auto new_end_2 = thrust::reduce_by_key(key_in.begin(),
                                     key_in.end(),
                                     uni_vect.begin(),
                                     key_out.begin(),
                                     num_in_bins.begin());

  thrust::host_vector<int> h_num_in_bins(new_size);
  thrust::copy(num_in_bins.begin(), num_in_bins.end(), h_num_in_bins.begin());

  for(int i=0; i < 10;i++)
  {
   std::cout << h_num_in_bins[i] << ","; // << std::endl;
  }
   std::cout << std::endl;

  return 0;
}
