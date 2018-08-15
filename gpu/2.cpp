#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>

#include <iostream>
#include <cstdlib>
#include "tbb/task_scheduler_init.h"
#include "tbb/parallel_sort.h"

using namespace std;
using namespace tbb;

int main(void)
{
  // generate 32M random numbers serially
  thrust::host_vector<int> h_vec(1024 << 20);
  std::generate(h_vec.begin(), h_vec.end(), rand);

  static int counter;

  task_scheduler_init init;

  // for(auto itr = h_vec.begin(); itr != h_vec.end(); ++itr) 
  tbb::parallel_sort(h_vec.begin(),h_vec.end());

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
