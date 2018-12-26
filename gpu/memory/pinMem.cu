#include "../common/common.h"
#include <cuda_runtime.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    int dev = 0;
    CHECK(cudaSetDevice(dev));

    unsigned int isize = 1 << 22;
    unsigned int nbytes = isize * sizeof(float);

    cudaDeviceProp deviceProp;
    CHECK(cudaGetDeviceProperties(&deviceProp, dev));

    if (!deviceProp.canMapHostMemory)
    {
        printf("Device %d does not support mapping CPU host memory!\n", dev);
        CHECK(cudaDeviceReset());
        exit(EXIT_SUCCESS);
    }

    printf("%s starting at ", argv[0]);
    printf("device %d: %s memory size %d nbyte %5.2fMB canMap %d\n", dev,
           deviceProp.name, isize, nbytes / (1024.0f * 1024.0f),
           deviceProp.canMapHostMemory);

    float *h_a;
    CHECK(cudaMallocHost ((float **)&h_a, nbytes));

    float *d_a;
    CHECK(cudaMalloc((float **)&d_a, nbytes));

    memset(h_a, 0, nbytes);

    for (int i = 0; i < isize; i++) h_a[i] = 100.10f;

    CHECK(cudaMemcpy(d_a, h_a, nbytes, cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(h_a, d_a, nbytes, cudaMemcpyDeviceToHost));

    CHECK(cudaFree(d_a));
    CHECK(cudaFreeHost(h_a));

    CHECK(cudaDeviceReset());
    return EXIT_SUCCESS;
}
