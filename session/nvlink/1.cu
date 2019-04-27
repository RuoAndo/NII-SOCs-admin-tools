#include <cuda_runtime.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <random>
#include <iostream>
#include <sys/time.h>
#include <thrust/system/cuda/vector.h>
#include <thrust/system/cuda/execution_policy.h>
#include <thrust/host_vector.h>
#include <thrust/generate.h>
#include <thrust/pair.h>
#include <cstdlib>
#include <iostream>
#include <map>
#include <cassert>


// This example demonstrates how to intercept calls to get_temporary_buffer
// and return_temporary_buffer to control how Thrust allocates temporary storage
// during algorithms such as thrust::sort. The idea will be to create a simple
// cache of allocations to search when temporary storage is requested. If a hit
// is found in the cache, we quickly return the cached allocation instead of
// resorting to the more expensive thrust::cuda::malloc.
//
// Note: this implementation cached_allocator is not thread-safe. If multiple
// (host) threads use the same cached_allocator then they should gain exclusive
// access to the allocator before accessing its methods.


// cached_allocator: a simple allocator for caching allocation requests
class cached_allocator
{
  public:
    // just allocate bytes
    typedef char value_type;

    cached_allocator() {}

    ~cached_allocator()
    {
      // free all allocations when cached_allocator goes out of scope
      free_all();
    }

    char *allocate(std::ptrdiff_t num_bytes)
    {
      char *result = 0;

      // search the cache for a free block
      free_blocks_type::iterator free_block = free_blocks.find(num_bytes);

      if(free_block != free_blocks.end())
      {
        std::cout << "cached_allocator::allocator(): found a hit" << std::endl;

        // get the pointer
        result = free_block->second;

        // erase from the free_blocks map
        free_blocks.erase(free_block);
      }
      else
      {
        // no allocation of the right size exists
        // create a new one with cuda::malloc
        // throw if cuda::malloc can't satisfy the request
        try
        {
          std::cout << "cached_allocator::allocator(): no free block found; calling cuda::malloc" << std::endl;

          // allocate memory and convert cuda::pointer to raw pointer
          result = thrust::cuda::malloc<char>(num_bytes).get();
        }
        catch(std::runtime_error &e)
        {
          throw;
        }
      }

      // insert the allocated pointer into the allocated_blocks map
      allocated_blocks.insert(std::make_pair(result, num_bytes));

      return result;
    }

    void deallocate(char *ptr, size_t n)
    {
      // erase the allocated block from the allocated blocks map
      allocated_blocks_type::iterator iter = allocated_blocks.find(ptr);
      std::ptrdiff_t num_bytes = iter->second;
      allocated_blocks.erase(iter);

      // insert the block into the free blocks map
      free_blocks.insert(std::make_pair(num_bytes, ptr));
    }

  private:
    typedef std::multimap<std::ptrdiff_t, char*> free_blocks_type;
    typedef std::map<char *, std::ptrdiff_t>     allocated_blocks_type;

    free_blocks_type      free_blocks;
    allocated_blocks_type allocated_blocks;

    void free_all()
    {
      std::cout << "cached_allocator::free_all(): cleaning up after ourselves..." << std::endl;

      // deallocate all outstanding blocks in both lists
      for(free_blocks_type::iterator i = free_blocks.begin();
          i != free_blocks.end();
          ++i)
      {
        // transform the pointer to cuda::pointer before calling cuda::free
        thrust::cuda::free(thrust::cuda::pointer<char>(i->second));
      }

      for(allocated_blocks_type::iterator i = allocated_blocks.begin();
          i != allocated_blocks.end();
          ++i)
      {
        // transform the pointer to cuda::pointer before calling cuda::free
        thrust::cuda::free(thrust::cuda::pointer<char>(i->first));
      }
    }

};




int main() {
    cached_allocator alloc;
    // size of arrays
    const int n = 300000000;

    // random number generator
    std::mt19937 rng;

    // key/val on host
    uint32_t * key = new uint32_t[n];
    uint32_t * val = new uint32_t[n];

    // fill key val
    for(int i = 0; i < n; i++) {
        key[i] = rng();
        val[i] = i;
    }

   // key/val on device
   uint32_t * dev_key;
   uint32_t * dev_val;

   // allocate memory on GPU for key/val
   cudaMalloc((void**)&dev_key, n*sizeof(uint32_t));
   cudaMalloc((void**)&dev_val, n*sizeof(uint32_t));

   // copy key/val onto the device
   cudaMemcpy(dev_key, key, n*sizeof(uint32_t), cudaMemcpyHostToDevice);
   cudaMemcpy(dev_val, val, n*sizeof(uint32_t), cudaMemcpyHostToDevice);

   // get thrust device pointers to key/val on device
   thrust::device_ptr<uint32_t> dev_key_ptr = thrust::device_pointer_cast(dev_key);
   thrust::device_ptr<uint32_t> dev_val_ptr = thrust::device_pointer_cast(dev_val);

   // data on host
   uint32_t * data;

   // allocate pinned memory for data on host
   cudaMallocHost((void**)&data, n*sizeof(uint32_t));

   // fill data with random numbers
   for(int i = 0; i < n; i++) {
       data[i] = rng();
   }

   // data on device
   uint32_t * dev_data;

   // allocate memory for data on the device
   cudaMalloc((void**)&dev_data, n*sizeof(uint32_t));

   // for timing
   struct timeval t1, t2;

   // two streams
   cudaStream_t stream1;
   cudaStream_t stream2;

   // create streams
   cudaStreamCreate(&stream1);
   cudaStreamCreate(&stream2);

   for(int i = 0; i < 10; i++) {

       // Copy data into dev_data on stream 1 (nothing happening on stream 2 for now)
       gettimeofday(&t1, NULL);
           cudaMemcpyAsync(dev_data, data, n*sizeof(uint32_t), cudaMemcpyHostToDevice, stream1);
           cudaDeviceSynchronize();
       gettimeofday(&t2, NULL);
       double t_copy = double(t2.tv_sec-t1.tv_sec)*1000.0 + double(t2.tv_usec-t1.tv_usec)/1000.0;


       // Sort_by_key on stream 2 (nothing hapenning on stream 1 for now)
       gettimeofday(&t1, NULL);
           thrust::sort_by_key(thrust::cuda::par(alloc).on(stream2), dev_key_ptr, dev_key_ptr + n, dev_val_ptr);
           cudaDeviceSynchronize();
       gettimeofday(&t2, NULL);
       double t_sort = double(t2.tv_sec-t1.tv_sec)*1000.0 + double(t2.tv_usec-t1.tv_usec)/1000.0;

       // Overlap both operations
       gettimeofday(&t1, NULL);
           thrust::sort_by_key(thrust::cuda::par(alloc).on(stream2), dev_key_ptr, dev_key_ptr + n, dev_val_ptr);
           cudaMemcpyAsync(dev_data, data, n*sizeof(uint32_t), cudaMemcpyHostToDevice, stream1);
           cudaDeviceSynchronize();
       gettimeofday(&t2, NULL);
       double t_both = double(t2.tv_sec-t1.tv_sec)*1000.0 + double(t2.tv_usec-t1.tv_usec)/1000.0;

       std::cout << "t_copy: " << t_copy << ", t_sort: " << t_sort << ", t_both1: " << t_both << std::endl;

   }

   // clean up
   cudaStreamDestroy(stream1);
   cudaStreamDestroy(stream2);
   cudaFreeHost(data);
   cudaFree(dev_data);
   cudaFree(dev_key);
   cudaFree(dev_val);
   delete [] key;
   delete [] val;

}
