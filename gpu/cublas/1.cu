#include "../common/common.h"
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "cublas_v2.h"

#include <time.h>

__global__ void initIdentityGPU(int **devMatrix, int numR, int numC) {
    int x = blockDim.x*blockIdx.x + threadIdx.x;
    int y = blockDim.y*blockIdx.y + threadIdx.y;
    if(y < numR && x < numC) {
          if(x == y)
              devMatrix[y][x] = 1;
          else
              devMatrix[y][x] = 0;
    }
}

int M = 10000;
int N = 10000;

void generate_random_vector(int N, float **outX)
{
    int i;
    double rMax = (double)RAND_MAX;
    float *X = (float *)malloc(sizeof(float) * N);

    for (i = 0; i < N; i++)
    {
        int r = rand();
        double dr = (double)r;
        X[i] = (dr / rMax) * 100.0;
    }

    *outX = X;
}

void generate_random_dense_matrix(int M, int N, float **outA)
{
    int i, j;
    double rMax = (double)RAND_MAX;
    float *A = (float *)malloc(sizeof(float) * M * N);

    // For each column
    for (j = 0; j < N; j++)
    {
        // For each row
        for (i = 0; i < M; i++)
        {
            double dr = (double)rand();
            A[j * M + i] = (dr / rMax) * 100.0;
        }
    }

    *outA = A;
}

void generate_identity_matrix(int M, int N, float **outA)
{
    int i, j;
    // double rMax = (double)RAND_MAX;
    float *A = (float *)malloc(sizeof(float) * M * N);

    // For each column
    for (j = 0; j < N; j++)
    {
        // For each row
        for (i = 0; i < M; i++)
        {
	    if(i == j)
	    	 A[N,M] = 1;
        }
    }

    *outA = A;
}

int main(int argc, char **argv)
{
    int i;
    float *A, *dA;
    float *I, *dI;
    float *X, *dX;
    float *Y, *dY;
    float beta;
    float alpha;
    cublasHandle_t handle = 0;

    struct timespec startTime, endTime, sleepTime;

    alpha = 3.0f;
    beta = 16.0f;

    srand(9384);
    generate_random_dense_matrix(M, N, &A);
    generate_random_vector(N, &X);
    generate_random_vector(M, &Y);
    generate_identity_matrix(M, N, &I);
    
    CHECK_CUBLAS(cublasCreate(&handle));

    CHECK(cudaMalloc((void **)&dA, sizeof(float) * M * N));
    CHECK(cudaMalloc((void **)&dX, sizeof(float) * N));
    CHECK(cudaMalloc((void **)&dY, sizeof(float) * M));

    CHECK_CUBLAS(cublasSetVector(N, sizeof(float), X, 1, dX, 1));
    CHECK_CUBLAS(cublasSetVector(M, sizeof(float), Y, 1, dY, 1));
    CHECK_CUBLAS(cublasSetMatrix(M, N, sizeof(float), A, M, dA, M));

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    CHECK_CUBLAS(cublasSgemv(handle, CUBLAS_OP_N, M, N, &alpha, dA, M, dX, 1,
                             &beta, dY, 1));

    clock_gettime(CLOCK_REALTIME, &endTime);

    printf("elapsed time:");

    if (endTime.tv_nsec < startTime.tv_nsec) {
    	      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
	      printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec, endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    // Retrieve the output vector from the device
    CHECK_CUBLAS(cublasGetVector(M, sizeof(float), dY, 1, Y, 1));

    /*
    for (i = 0; i < 10; i++)
    {
        printf("%2.2f\n", Y[i]);
    }
    */

    printf("...\n");

    free(A);
    free(X);
    free(Y);

    CHECK(cudaFree(dA));
    CHECK(cudaFree(dY));
    CHECK_CUBLAS(cublasDestroy(handle));

    return 0;
}
