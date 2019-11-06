#include <stdio.h>
#include <cublas_v2.h>
#include <time.h>
#include <sys/time.h>
#define uS_PER_SEC 1000000
#define uS_PER_mS 1000
#define N  1000
#define M 1000

int main(){

    timeval t1, t2;
    float *matrix = (float *) malloc (N * M * sizeof(float));
// Starting the timer
    gettimeofday(&t1, NULL);
    float *matrixT = (float *) malloc (N * M * sizeof(float));
    for (int i = 0; i < N; i++)
        for (int j = 0; j < M; j++)
            matrixT[(j*N)+i] = matrix[(i*M)+j]; // matrix is obviously filled

//Ending the timer
    gettimeofday(&t2, NULL);
    float et1 = (((t2.tv_sec*uS_PER_SEC)+t2.tv_usec) - ((t1.tv_sec*uS_PER_SEC)+t1.tv_usec))/(float)uS_PER_mS;
    printf("CPU time = %fms\n", et1);

    float *h_matrixT , *d_matrixT , *d_matrix;
    h_matrixT = (float *) (malloc (N * M * sizeof(float)));
    cudaMalloc((void **)&d_matrixT , N * M * sizeof(float));
    cudaMalloc((void**)&d_matrix , N * M * sizeof(float));
    cudaMemcpy(d_matrix , matrix , N * M * sizeof(float) , cudaMemcpyHostToDevice);

//Starting the timer
    gettimeofday(&t1, NULL);

    const float alpha = 1.0;
    const float beta  = 0.0;
    // gettimeofday(&t1, NULL);
    cublasHandle_t handle;
    cublasCreate(&handle);
    gettimeofday(&t1, NULL);
    cublasSgeam(handle, CUBLAS_OP_T, CUBLAS_OP_N, N, M, &alpha, d_matrix, M, &beta, d_matrix, N, d_matrixT, N);
    cudaDeviceSynchronize();
    gettimeofday(&t2, NULL);
    cublasDestroy(handle);
//Ending the timer
    float et2 = (((t2.tv_sec*uS_PER_SEC)+t2.tv_usec) - ((t1.tv_sec*uS_PER_SEC)+t1.tv_usec))/(float)uS_PER_mS;
    printf("GPU time = %fms\n", et2);

    cudaMemcpy(h_matrixT , d_matrixT , N * M * sizeof(float) , cudaMemcpyDeviceToHost);


    cudaFree(d_matrix);
    cudaFree(d_matrixT);
    return 0;
}


