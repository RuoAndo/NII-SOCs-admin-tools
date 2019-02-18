
#ifndef __CUDACC__
#define __CUDACC__
#endif
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <cuda.h>
#include <device_functions.h>
#include <cuda_runtime_api.h>

#include <stdio.h>
#include <iostream>
#include <cstdio>

#define N 1024
#define THREADS 32
#define BLOCKS 32


cudaError_t sortCuda(unsigned int *data, const int size);

__global__ void sort(unsigned int *data) {
        int i = 2;
        __shared__ int temp[THREADS];

        while (i <= THREADS) {
          if ((threadIdx.x % i) == 0) {
                int index1 = threadIdx.x + (blockIdx.x * blockDim.x);
				int targetIndex = threadIdx.x;
                int endIndex1 = index1 + i/2;
                int index2 = endIndex1;
                int endIndex2 = index2 + i/2;
                
                while (!((index1==endIndex1) && (index2==endIndex2))) {
                        if ((index1 == endIndex1) && (index2 < endIndex2))
							temp[targetIndex++] = data[index2++];
                        else if ((index2 == endIndex2) && (index1 < endIndex1))
							temp[targetIndex++] = data[index1++];
                        else if (data[index1] < data[index2])
							temp[targetIndex++] = data[index1++];
                        else
							temp[targetIndex++] = data[index2++];
                }
          }
		  __syncthreads();
          data[threadIdx.x + (blockIdx.x*blockDim.x)] = temp[threadIdx.x];
          __syncthreads();
          i *= 2;
        }
}

__global__ void merge(unsigned int *data, unsigned int *final, int sortedsize) {
		int index1 = blockIdx.x * 2 * sortedsize;
		int targetIndex = blockIdx.x * 2 * sortedsize;
        int endIndex1 = index1 + sortedsize;
        int index2 = endIndex1;
        int endIndex2 = index2 + sortedsize;
   
        while (!((index1==endIndex1) && (index2==endIndex2))) {
                if ((index1 == endIndex1) && (index2 < endIndex2))
					final[targetIndex++] = data[index2++];
                else if ((index2 == endIndex2) && (index1 < endIndex1))
					final[targetIndex++] = data[index1++];
                else if (data[index1] < data[index2])
					final[targetIndex++] = data[index1++];
                else
					final[targetIndex++] = data[index2++];
        }
}


void init_data(unsigned int *data, unsigned int nitems) {
  for (unsigned i = 0 ; i < nitems ; i++)
    data[i] = rand() % nitems ;
}

int main() {
	unsigned int *h_data = 0;

	std::cout << "Initializing data:" << std::endl;
	h_data =(unsigned int *)malloc( N*sizeof(unsigned int));
	init_data(h_data, N);
	//for(int i=0 ; i<N ; i++)
	//	std::cout << "Data [" << i << "]: " << h_data[i] << std::endl;

    cudaError_t cudaStatus = sortCuda(h_data, N);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "sortCuda failed!");
        return 1;
    }
	
	std::cout << "Results after sorting:" << std::endl;
	for(int i=0 ; i<N ; i++)
		std::cout << "Data [" << i << "]: " << h_data[i] << std::endl;

    cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceReset failed!");
        return 1;
    }

    return 0;
}

// Helper function for using CUDA to add vectors in parallel.
cudaError_t sortCuda(unsigned int *data, const int size) {
    unsigned int *dev_data = 0;
	unsigned int *dev_final = 0;
    cudaError_t cudaStatus;

	cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        // goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_data, size * sizeof(unsigned int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        // goto Error;
    }

	cudaStatus = cudaMalloc((void**)&dev_final, size * sizeof(unsigned int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        // goto Error;
    }

    cudaStatus = cudaMemcpy(dev_data, data, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        // goto Error;
    }

	std::cout << "Launching kernel on the GPU" << std::endl;
	//quicksort<<< 1, size >>>(dev_data);
	sort<<<BLOCKS,THREADS>>>(dev_data);
	int blocks = BLOCKS/2;
    int sortedsize = THREADS;
    while (blocks > 0) {
		merge<<<blocks,1>>>(dev_data, dev_final, sortedsize);
		cudaMemcpy(dev_data, dev_final, N*sizeof(int), cudaMemcpyDeviceToDevice);
		blocks /= 2;
		sortedsize *= 2;
	}

    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "sortKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        // goto Error;
    }
	    
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching sortKernel!\n", cudaStatus);
        // goto Error;
    }

    cudaStatus = cudaMemcpy(data, dev_data, size * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        // goto Error;
    }

Error:
    cudaFree(dev_data);
	cudaFree(dev_final);
    
    return cudaStatus;
}
