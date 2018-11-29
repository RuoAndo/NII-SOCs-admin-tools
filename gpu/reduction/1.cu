#include "../common/common.h"
#include <cuda_runtime.h>
#include <stdio.h>

int recursiveReduceWithStrideOnCPU(int *data, int const size)
{
    if (size == 1) return data[0];

    int const stride = size / 2;
    
    for (int i = 0; i < stride; i++)
    {
        data[i] += data[i + stride];
    }
    return recursiveReduceWithStrideOnCPU(data, stride);
}

__global__ void reduceNeighbored (int *g_idata, int *g_odata, unsigned int n)
{
    unsigned int tid = threadIdx.x;
    unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;

    int *idata = g_idata + blockIdx.x * blockDim.x;

    if (idx >= n) return;
    
    for (int stride = 1; stride < blockDim.x; stride *= 2)
    {
        if ((tid % (2 * stride)) == 0)
        {
            idata[tid] += idata[tid + stride];
        }

        __syncthreads();
    }

    if (tid == 0) g_odata[blockIdx.x] = idata[0];
}

__global__ void reduceneighboredwithoutIF (int *g_idata, int *g_odata,
                                      unsigned int n)
{
    unsigned int tid = threadIdx.x;
    unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;

    int *idata = g_idata + blockIdx.x * blockDim.x;

    if(idx >= n) return;

    for (int stride = 1; stride < blockDim.x; stride *= 2)
    {
        int index = 2 * stride * tid;

        if (index < blockDim.x)
        {
            idata[index] += idata[index + stride];
        }
        __syncthreads();
    }
    
    if (tid == 0) g_odata[blockIdx.x] = idata[0];
}

int main(int argc, char **argv)
{
    int dev = 0;
    cudaDeviceProp deviceProp;
    CHECK(cudaGetDeviceProperties(&deviceProp, dev));
    printf("%s starting reduction at ", argv[0]);
    printf("device %d: %s ", dev, deviceProp.name);
    CHECK(cudaSetDevice(dev));

    bool bResult = false;

    int size = 1 << 24; 
    printf("    with array size %d  ", size);

    // execution configuration
    int blocksize = 512;

    if(argc > 1)
    {
        blocksize = atoi(argv[1]);  
    }

    dim3 block (blocksize, 1);
    dim3 grid  ((size + block.x - 1) / block.x, 1);
    printf("grid %d block %d\n", grid.x, block.x);

    size_t bytes = size * sizeof(int);
    int *h_idata = (int *) malloc(bytes);
    int *h_odata = (int *) malloc(grid.x * sizeof(int));
    int *tmp     = (int *) malloc(bytes);

    for (int i = 0; i < size; i++)
    {
        h_idata[i] = (int)( rand() & 0xFF );
    }

    memcpy (tmp, h_idata, bytes);

    double iStart, iElaps;
    int gpu_sum = 0;

    int *d_idata = NULL;
    int *d_odata = NULL;
    CHECK(cudaMalloc((void **) &d_idata, bytes));
    CHECK(cudaMalloc((void **) &d_odata, grid.x * sizeof(int)));

    iStart = seconds();
    int cpu_sum = recursiveReduceWithStrideOnCPU (tmp, size);
    iElaps = seconds() - iStart;
    printf("cpu reduce      elapsed %f sec cpu_sum: %d\n", iElaps, cpu_sum);

    // kernel 1: reduceNeighbored
    CHECK(cudaMemcpy(d_idata, h_idata, bytes, cudaMemcpyHostToDevice));
    CHECK(cudaDeviceSynchronize());
    iStart = seconds();
    reduceNeighbored<<<grid, block>>>(d_idata, d_odata, size);
    CHECK(cudaDeviceSynchronize());
    iElaps = seconds() - iStart;
    CHECK(cudaMemcpy(h_odata, d_odata, grid.x * sizeof(int),
                     cudaMemcpyDeviceToHost));
    gpu_sum = 0;

    for (int i = 0; i < grid.x; i++) gpu_sum += h_odata[i];

    printf("gpu Neighbored  elapsed %f sec gpu_sum: %d <<<grid %d block "
           "%d>>>\n", iElaps, gpu_sum, grid.x, block.x);

    CHECK(cudaMemcpy(d_idata, h_idata, bytes, cudaMemcpyHostToDevice));
    CHECK(cudaDeviceSynchronize());
    iStart = seconds();
    reduceneighboredwithoutIF<<<grid, block>>>(d_idata, d_odata, size);
    CHECK(cudaDeviceSynchronize());
    iElaps = seconds() - iStart;
    CHECK(cudaMemcpy(h_odata, d_odata, grid.x * sizeof(int),
                     cudaMemcpyDeviceToHost));
    gpu_sum = 0;

    for (int i = 0; i < grid.x; i++) gpu_sum += h_odata[i];

    printf("gpu Neighbored2 elapsed %f sec gpu_sum: %d <<<grid %d block "
           "%d>>>\n", iElaps, gpu_sum, grid.x, block.x);

    CHECK(cudaFree(d_idata));
    CHECK(cudaFree(d_odata));
    CHECK(cudaDeviceReset());

    bResult = (gpu_sum == cpu_sum);
    if(!bResult) printf("Test failed!\n");

    return EXIT_SUCCESS;
}
