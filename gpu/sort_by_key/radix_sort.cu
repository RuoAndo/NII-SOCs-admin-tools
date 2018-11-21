// -*- compile-command: "nvcc -D THRUST_SORT_TYPE=uint32_t -arch sm_50 -o sort sort_32.cu"; -*-

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <algorithm>
#include <cstdlib>

//
//
//

#include <stdbool.h>

static
void
cuda_assert(const cudaError_t code, const char* const file, const int line, const bool abort)
{
  if (code != cudaSuccess)
    {
      fprintf(stderr,"cuda_assert: %s %s %d\n",cudaGetErrorString(code),file,line);

      if (abort)
        {
          cudaDeviceReset();
          exit(code);
        }
    }
}

#define cuda(...) { cuda_assert((cuda##__VA_ARGS__), __FILE__, __LINE__, true); }

//
//
//

#ifndef THRUST_SORT_TYPE
#define THRUST_SORT_TYPE   uint64_t
#endif

#define THRUST_SORT_WARMUP 100
#define THRUST_SORT_BENCH  100

//
//
//

static
void
sort(thrust::device_vector<THRUST_SORT_TYPE>& d_vec,
     cudaEvent_t                              start,
     cudaEvent_t                              end,
     float                                  * min_ms,
     float                                  * max_ms,
     float                                  * elapsed_ms)
{
  cuda(EventRecord(start,0));

  thrust::sort(d_vec.begin(), d_vec.end());

  cuda(EventRecord(end,0));
  cuda(EventSynchronize(end));

  float t_ms;
  cuda(EventElapsedTime(&t_ms,start,end));

  *min_ms      = min(*min_ms,t_ms);
  *max_ms      = max(*max_ms,t_ms);
  *elapsed_ms += t_ms;
}

//
//
//

static
void
bench(const struct cudaDeviceProp* const props, const uint32_t count)
{
  thrust::host_vector<THRUST_SORT_TYPE> h_vec(count);

  // random fill
  std::generate(h_vec.begin(), h_vec.end(), rand);

  // transfer data to the device
  thrust::device_vector<THRUST_SORT_TYPE> d_vec = h_vec;

  cudaEvent_t start, end;
  cuda(EventCreate(&start));
  cuda(EventCreate(&end));

  float min_ms     = FLT_MAX;
  float max_ms     = 0.0f;
  float elapsed_ms = 0.0f;

  for (int ii=0; ii<THRUST_SORT_WARMUP; ii++)
    sort(d_vec,start,end,&min_ms,&max_ms,&elapsed_ms);

  min_ms     = FLT_MAX;
  max_ms     = 0.0f;
  elapsed_ms = 0.0f;

  for (int ii=0; ii<THRUST_SORT_BENCH; ii++)
    sort(d_vec,start,end,&min_ms,&max_ms,&elapsed_ms);

  cuda(EventDestroy(start));
  cuda(EventDestroy(end));

  //
  //
  //
#define STRINGIFY2(s) #s
#define STRINGIFY(s)  STRINGIFY2(s)

  fprintf(stdout,"%s, %u, %s, %u, %u, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f\n",
          props->name,
          props->multiProcessorCount,
          STRINGIFY(THRUST_SORT_TYPE),
          count,
          THRUST_SORT_BENCH,
          elapsed_ms,
          (double)elapsed_ms / THRUST_SORT_BENCH,
          (double)min_ms,
          (double)max_ms,
          (double)(THRUST_SORT_BENCH * count) / (1000.0 * elapsed_ms),
          (double)count                       / (1000.0 * min_ms));
}

//
//
//

int
main(int argc, char** argv)
{
  const int32_t device = (argc == 1) ? 0 : atoi(argv[1]);

  struct cudaDeviceProp props;
  cuda(GetDeviceProperties(&props,device));

  printf("%s (%2d)\n",props.name,props.multiProcessorCount);

  cuda(SetDevice(device));

  //
  //
  //
  const uint32_t count_lo   = argc <= 2 ? 2048   : strtoul(argv[2],NULL,0);
  // const uint32_t count_hi   = argc <= 3 ? 262144 : strtoul(argv[3],NULL,0);
  // const uint32_t count_hi   = argc <= 3 ? 1024 << 21 : strtoul(argv[3],NULL,0);
  const uint32_t count_hi   = argc <= 3 ? 100000000 : strtoul(argv[3],NULL,0);
  const uint32_t count_step = argc <= 4 ? 2048   : strtoul(argv[4],NULL,0);

  //
  // LABELS
  //
  fprintf(stdout,
          "Device, "
          "Multiprocessors, "
          "Type, "
          "Keys, "
          "Trials, "
          "Total Msecs, "
          "Avg. Msecs, "
          "Min Msecs, "
          "Max Msecs, "
          "Avg. Mkeys/s, "
          "Max. Mkeys/s\n");

  //
  // SORT
  //
  for (uint32_t count=count_lo; count<=count_hi; count+=count_step)
    bench(&props,count);

  //
  // RESET
  //
  cuda(DeviceReset());

  return 0;
}
