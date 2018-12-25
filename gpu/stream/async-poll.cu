#include "../common/common.h"
#include <stdio.h>
#include <cuda_runtime.h>

__global__ void kernel_for_sum(float *g_data, float value)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    g_data[idx] = g_data[idx] + value;
}

int inspectResult(float *data, const int n, const float x)
{
    for (int i = 0; i < n; i++)
    {
        if (data[i] != x)
        {
            printf("Error! data[%d] = %f, ref = %f\n", i, data[i], x);
            return 0;
        }
    }

    return 1;
}

int main(int argc, char *argv[])
{
    int devID = 0;
    cudaDeviceProp deviceProps;
    CHECK(cudaGetDeviceProperties(&deviceProps, devID));
    printf("> %s running on", argv[0]);
    printf(" CUDA device [%s]\n", deviceProps.name);

    int num = 1 << 24;
    int nbytes = num * sizeof(int);
    float value = 10.0f;

    // allocate host memory
    float *h_a = 0;
    CHECK(cudaMallocHost((void **)&h_a, nbytes));
    memset(h_a, 0, nbytes);

    float *d_a = 0;
    CHECK(cudaMalloc((void **)&d_a, nbytes));
    CHECK(cudaMemset(d_a, 255, nbytes));

    dim3 block = dim3(512);
    dim3 grid  = dim3((num + block.x - 1) / block.x);

    cudaEvent_t stop;
    CHECK(cudaEventCreate(&stop));

    CHECK(cudaMemcpyAsync(d_a, h_a, nbytes, cudaMemcpyHostToDevice));
    kernel_for_sum<<<grid, block>>>(d_a, value);
    CHECK(cudaMemcpyAsync(h_a, d_a, nbytes, cudaMemcpyDeviceToHost));
    CHECK(cudaEventRecord(stop, 0));

    unsigned long int counter = 0;

    // polling
    while (cudaEventQuery(stop) == cudaErrorNotReady) {
        counter++;
    }

    printf("CPU executed %lu iterations while waiting for GPU to finish\n", counter);

    bool bFinalResults = (bool) inspectResult(h_a, num, value);

    CHECK(cudaEventDestroy(stop));
    CHECK(cudaFreeHost(h_a));
    CHECK(cudaFree(d_a));

    CHECK(cudaDeviceReset());

    exit(bFinalResults ? EXIT_SUCCESS : EXIT_FAILURE);
}
