#include <cuda_runtime.h>
#include <stdio.h>
#include <sys/time.h>

double cpuSecond()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double)tp.tv_sec + (double)tp.tv_usec * 1.e-6);
}

#define CHECK(call)                                                  \
{                                                                    \
    const cudaError_t error = call;                                  \
    if (error != cudaSuccess)                                        \
    {                                                                \
        printf("Error: %s:%d, ", __FILE__, __LINE__);                \
        printf("code:%d, reason: %s\n", error,                       \
                cudaGetErrorString(error));                          \
        exit(1);                                                     \
    }                                                                \
}

void checkResult(float *hostRef, float *gpuRef, const int N)
{
    double epsilon = 1.0E-8;
    bool match = 1;

    for (int i = 0; i < N; i++)
    {
        if (abs(hostRef[i] - gpuRef[i]) > epsilon)
        {
            match = 0;
            printf("Arrays do not match!\n");
            printf("host %5.2f gpu %5.2f at current %d\n", hostRef[i], gpuRef[i], i);
            break;
        }
    }

    if (match) printf("Arrays match.\n\n");

    return;
}

void initialData(float *ip, int size)
{
    time_t t;
    srand((unsigned) time(&t));

    for (int i = 0; i < size; i++)
    {
        ip[i] = (float)( rand() & 0xFF ) / 10.0f;
    }

    return;
}

void sumOnHost(float *A, float *B, float *C, const int N)
{
    for (int idx = 0; idx < N; idx++)
    {
        C[idx] = A[idx] + B[idx];
    }
}
__global__ void sumOnGPU(float *A, float *B, float *C, const int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) C[i] = A[i] + B[i];
}

int main(int argc, char **argv)
{

    int dev = 0;
    cudaDeviceProp deviceProp;
    CHECK(cudaGetDeviceProperties(&deviceProp, dev));
    // printf("Device name %d: %s\n", dev, deviceProp.name);
    CHECK(cudaSetDevice(dev));

    int nElement = 1 << atoi(argv[1]);
    printf("Vector size %d\n", nElement);

    // malloc host memory
    size_t nBytes = nElement * sizeof(float);

    float *hostA, *hostB, *hostRef, *gpuRef;
    hostA     = (float *)malloc(nBytes);
    hostB     = (float *)malloc(nBytes);
    hostRef = (float *)malloc(nBytes);
    gpuRef  = (float *)malloc(nBytes);

    double iStart, iElaps_device, iElaps_host, iRatio;

    iStart = cpuSecond();
    initialData(hostA, nElement);
    initialData(hostB, nElement);
    iElaps_host = cpuSecond() - iStart;
    
    memset(hostRef, 0, nBytes);
    memset(gpuRef,  0, nBytes);

    iStart = cpuSecond();
    sumOnHost(hostA, hostB, hostRef, nElement);
    iElaps_host = cpuSecond() - iStart;
    printf("sumOnHost : Time elapsed %f sec\n", iElaps_host);
    
    float *device_A, *device_B, *device_C;
    CHECK(cudaMalloc((float**)&device_A, nBytes));
    CHECK(cudaMalloc((float**)&device_B, nBytes));
    CHECK(cudaMalloc((float**)&device_C, nBytes));

    CHECK(cudaMemcpy(device_A, hostA, nBytes, cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(device_B, hostB, nBytes, cudaMemcpyHostToDevice));
    CHECK(cudaMemcpy(device_C, gpuRef, nBytes, cudaMemcpyHostToDevice));

    // invoke kernel at host side
    //int iLen = 512;
    int iLen = atoi(argv[2]);
    dim3 block (iLen);
    dim3 grid  ((nElement + block.x - 1) / block.x);

    iStart = cpuSecond();
    sumOnGPU<<<grid, block>>>(device_A, device_B, device_C, nElement);
    CHECK(cudaDeviceSynchronize());
    iElaps_device = cpuSecond() - iStart;
    printf("sumOnGPU %d, %d : Time elapsed %f sec\n", grid.x, block.x, iElaps_device);

    iRatio = iElaps_host / iElaps_device;
    printf("ratio %f \n", iRatio); 

    CHECK(cudaGetLastError()) ;

    CHECK(cudaMemcpy(gpuRef, device_C, nBytes, cudaMemcpyDeviceToHost));

    // checkResult(hostRef, gpuRef, nElement);

    CHECK(cudaFree(device_A));
    CHECK(cudaFree(device_B));
    CHECK(cudaFree(device_C));

    free(hostA);
    free(hostB);
    free(hostRef);
    free(gpuRef);

    return(0);
}
