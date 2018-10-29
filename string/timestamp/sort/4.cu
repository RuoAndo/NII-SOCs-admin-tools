#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/copy.h>
#include <thrust/sort.h>
#include <thrust/functional.h>
#include <iostream>
#include <iterator>

int main() {
  thrust::host_vector<int> host_input{5, 1, 9, 3, 7};
  thrust::device_vector<int> device_vec(5);

  thrust::copy(host_input.begin(), host_input.end(), device_vec.begin());

  // 昇順でソートする
  thrust::sort(device_vec.begin(), device_vec.end());

  thrust::copy(device_vec.begin(), device_vec.end(), std::ostream_iterator<int>(std::cout, ", "));
  // 1, 3, 5, 7, 9

  // 降順でソートする
  thrust::sort(device_vec.begin(), device_vec.end(), thrust::greater<int>());

  thrust::copy(device_vec.begin(), device_vec.end(), std::ostream_iterator<int>(std::cout, ", "));
  // 9, 7, 5, 3, 1

  return 0;
}
