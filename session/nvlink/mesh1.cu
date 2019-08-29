// #include "../common/common.h"
#include <stdlib.h>
#include <stdio.h>
#include <cuda_runtime.h>

inline bool isCapableP2P(int ngpus)
{
    cudaDeviceProp *prop = (cudaDeviceProp *)malloc(ngpus * sizeof(cudaDeviceProp));

    int iCount = 0;

    for (int i = 0; i < ngpus; i++)
    {
        cudaGetDeviceProperties(&prop[i], i);

        if (prop[i].major >= 2) iCount++;

        printf("> GPU%d: %s %s capable of Peer-to-Peer access\n",
               i, prop[i].name, (prop[i].major >= 2 ? "is" : "not"));
    }

    if (iCount != ngpus)
    {
        printf("> no enough device to run this application\n");
    }

    return (iCount == ngpus);
}

inline void enableP2P(int ngpus)
{
    for (int i = 0; i < ngpus; i++)
    {
        cudaSetDevice(i);

        for (int j = 0; j < ngpus; j++)
        {
            if (i == j) continue;

            int peer_access_available = 0;
            cudaDeviceCanAccessPeer(&peer_access_available, i, j);

            if (peer_access_available)
            {
                cudaDeviceEnablePeerAccess(j, 0);
                printf("> GPU%d enabled direct access to GPU%d\n", i, j);
            }
            else
            {
                printf("(%d, %d)\n", i, j );
            }
        }
    }
}

inline void disableP2P(int ngpus)
{
    for (int i = 0; i < ngpus; i++)
    {
        cudaSetDevice(i);

        for (int j = 0; j < ngpus; j++)
        {
            if (i == j) continue;

            int peer_access_available = 0;
            cudaDeviceCanAccessPeer(&peer_access_available, i, j);

            if (peer_access_available)
            {
                cudaDeviceDisablePeerAccess(j);
                printf("> GPU%d disabled direct access to GPU%d\n", i, j);
            }
        }
    }
}

void initialData(float *ip, int size)
{
    for (int i = 0; i < size; i++)
    {
        ip[i] = (float)rand() / (float)RAND_MAX;
    }
}

int main(int argc, char **argv)
{
    int ngpus;

    int N;
    N = atoi(argv[1]);

    ngpus = 3;
    isCapableP2P(ngpus);

    printf("ngpus %d \n", ngpus);

    if (ngpus > 1) enableP2P(ngpus);

    int iSize = 1024 * 1024 * N;
    const size_t iBytes = iSize * sizeof(float);
    printf("\nAllocating buffers (%iMB on each GPU and CPU Host)...\n",
           int(iBytes / 1024 / 1024));

    float **d_src = (float **)malloc(sizeof(float) * ngpus);
    float **d_rcv = (float **)malloc(sizeof(float) * ngpus);
    float **h_src = (float **)malloc(sizeof(float) * ngpus);
    cudaStream_t *stream = (cudaStream_t *)malloc(sizeof(cudaStream_t) * ngpus);

    cudaEvent_t start, stop;
    cudaSetDevice(0);
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    for (int i = 0; i < ngpus; i++)
    {
        cudaSetDevice(i);
        cudaMalloc(&d_src[i], iBytes);
        cudaMalloc(&d_rcv[i], iBytes);
        cudaMallocHost((void **) &h_src[i], iBytes);
        cudaStreamCreate(&stream[i]);
    }

    /*
    for (int i = 0; i < ngpus; i++)
    {
        initialData(h_src[i], iSize);
    }
    */

    cudaSetDevice(0);
    cudaEventRecord(start, 0);

    /*
    for (int i = 0; i < 100; i++)
    {
        if (i % 2 == 0)
        {
            cudaMemcpy(d_src[1], d_src[2], iBytes, cudaMemcpyDeviceToDevice);
        }
        else
        {
            cudaMemcpy(d_src[2], d_src[1], iBytes, cudaMemcpyDeviceToDevice);
        }
    }
    */

    float elapsed_time_ms;

    for (int i = 0; i < ngpus; i++)
    {
        for (int j = 0; j < ngpus; j++)
	{
		cudaEventRecord(start, 0);
		// printf("GPU%d -> GPU%d \n", i, j);
		cudaMemcpy(d_src[i], d_src[j], iBytes, cudaMemcpyDeviceToDevice);
		cudaEventRecord(stop, 0);
    		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&elapsed_time_ms, start, stop);
		elapsed_time_ms /= 100.0f;
		printf("GPU%d->GPU%d: performance: %8.2f GB/s\n", i, j, (float)iBytes / (elapsed_time_ms * 1e6f));		
	}
    }

    // cudaEventRecord(stop, 0);
    // cudaEventSynchronize(stop);

    // float elapsed_time_ms;
    // cudaEventElapsedTime(&elapsed_time_ms, start, stop);

    // elapsed_time_ms /= 100.0f;
    // printf("Ping-pong unidirectional cudaMemcpy:\t %8.2f ms ", elapsed_time_ms);
    // printf("performance: %8.2f GB/s\n\n", (float)iBytes / (elapsed_time_ms * 1e6f));

    cudaSetDevice(0);
    disableP2P(ngpus);

    // free
    cudaSetDevice(0);

    for (int i = 0; i < ngpus; i++)
    {
        cudaSetDevice(i);
        cudaFree(d_src[i]);
        cudaFree(d_rcv[i]);
        cudaStreamDestroy(stream[i]);
        // cudaDeviceReset();
    }

    exit(EXIT_SUCCESS);
}
