#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>
#include <thrust/uninitialized_copy.h>
#include <thrust/device_malloc.h>
#include <thrust/device_vector.h>

struct is_even
{
  __host__ __device__
    bool operator()(const int x)
      {
          return x < 1;
	    }
};

struct Int
{
  __host__ __device__
    Int(int x) : val(x) {}
      int val;
};  

/*
struct is_even
{
  __host__ __device__
    bool operator()(const int x)
      {
          return (x % 2) == 0;
	    }
};
*/

struct is_smaller_than_10 {
    __host__ __device__ bool operator()(const int a) const {
            return (a<1);
	    }
};

int main(void)
{
  int i, counter;

  int N = 1024 << 18;

  // generate 32M random numbers serially
  thrust::host_vector<int> h_vec_0(N);
  std::generate(h_vec_0.begin(), h_vec_0.end(), rand );

  // int h_A[1024 << 8];

  counter = 0;
  thrust::host_vector<int> h_vec(N);
  for(auto itr = h_vec_0.begin(); itr != h_vec_0.end(); ++itr) {
  	   h_vec[counter]= ((int)*itr)%2;
	   // h_A[counter]= ((int)*itr)%2;
	   counter = counter + 1;
  }

  // static int counter;

  // transfer data to the device
  thrust::device_vector<int> d_vec = h_vec;

  std::cout << d_vec.size() << std::endl;
  for(i=0; i< 10; i++) 
  	   std::cout << h_vec[i] << ",";
  std::cout << std::endl;

  /*
  thrust::device_vector<int> d_vec_2(d_vec.size());
  thrust::copy_if(d_vec.begin(), d_vec.end(), d_vec_2.begin(), is_even());
  std::cout << d_vec_2.size() << std::endl;
  */

  int N_prime = thrust::count_if(d_vec.begin(), d_vec.end(), is_smaller_than_10());
  thrust::device_vector<float> d_b(N_prime);
  thrust::copy_if(d_vec.begin(), d_vec.end(), d_b.begin(), is_smaller_than_10());
  std::cout << d_b.size() << std::endl;

  for(i=0; i< 10; i++) 
  	   std::cout << d_b[i] << ",";
  std::cout << std::endl;

  //sum = thrust::reduce(d_b.begin(), d_b.begin() + N_prime, 0.f);
	//         printf("Result = %fn",sum);


  // thrust::device_vector<int>* d_vec_2 = new thrust::device_vector<int>(d_vec.size(), false);
  // thrust::remove_if(d_vec.begin(), d_vec.end(), d_vec_2.begin(), is_even());

  // std::cout << d_vec.size() << std::endl;
  // thrust::device_vector<int>::iterator endIterator =  thrust::remove_if(d_vec.begin(), d_vec.end(), d_vec_2->begin(), is_even());
  // std::cout << (int)endIterator << std::endl;
  // thrust::host_vector<int> testEntries(d_vec.begin(), endIterator);
  // std::cout << testEntries.size() << std::endl;

  /*
  std::cout << d_vec.size() << std::endl;
  thrust::remove(d_vec.begin(), d_vec.end(), 1);
  std::cout << d_vec.size() << std::endl;
  */

  //thrust::device_ptr<Int> array = thrust::device_malloc<Int>(1024 << 8);
  //thrust::uninitialized_copy_n(d_vec_2.begin(), 1024 << 8 , array);
  //std::cout << array.size() << std::endl;  				

  // thrust::uninitialized_copy_if(d_vec.begin(), d_vec.end(), array, is_even());
  // int *new_end = thrust::remove(h_A, h_A + (1024 << 8), 1);
  //std::cout << (int)*new_end << std::endl;
  // sort data on the device (846M keys per second on GeForce GTX 480
  // thrust::sort(d_vec.begin(), d_vec.end());

  // transfer data back to host
  // thrust::copy(d_vec.begin(), d_vec.end(), h_vec.begin());
  
  //thrust::device_vector<int> pointer(d_vec.size(), 0);

  // thrust::device_vector<int> d_vec_2(d_vec.size());
  // thrust::device_vector<int> d_vec_2;  
  // thrust::remove_copy(d_vec.begin(), d_vec.end(), d_vec_2.begin(),0);

  // std::cout << d_vec.size() << std::endl;
  // thrust::copy_if(d_vec.begin(), d_vec.end(), d_vec_2.begin(), is_even());
  // std::cout << d_vec_2.size() << std::endl;

  // thrust::host_vector<int> h_vec_2 = d_vec_2;  
  // std::cout << h_vec_2.size() << std::endl;

  /*
  thrust::inclusive_scan(d_vec.begin(), d_vec.end(), pointer.begin() + 1);

  for(auto itr = pointer.begin(); itr != pointer.end(); ++itr) {
  	   std::cout << *itr << ",";
	   }
  */

  counter = 0;
  for(auto itr = h_vec.begin(); itr != h_vec.end(); ++itr) {

  	   /*
  	   if(counter < 10)
	             std::cout << *itr << ",";
           */

           counter = counter + 1;
  }

  return 0;
}
