#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "cublas_v2.h"
#include <time.h>


// #define RAND_MAX 100

void generate_random_vector(int N, float **outX)
{
    int i;
    double rMax = (double)RAND_MAX;
    float *X = (float *)malloc(sizeof(float) * N);

    for (i = 0; i < N; i++)
    {
        srand((unsigned int)time(NULL));
        int r = rand();
        double dr = (double)r;
        X[i] = (dr / rMax) * 100.0;
    }

    *outX = X;
}

int main()
{
  // timeval st,et;
float *hstA,*hstB,*hstC;
float *devA,*devB,*devC;

float alpha = 1.0f;
float beta = 1.0f;

int num =100;

int n2 = num*num;
size_t memSz = n2 * sizeof(float);

hstA=(float*)malloc(memSz);
hstB=(float*)malloc(memSz);
hstC=(float*)malloc(memSz);

/* insertion */
generate_random_vector(memSz, &hstA);
generate_random_vector(memSz, &hstB);
generate_random_vector(memSz, &hstC);

for(int i = 0; i < 10; i++)
     printf("%lf ", hstA[i]);    
printf("\n");

 for(int i = 0; i < 10; i++)
     printf("%lf ", hstB[i]);    
printf("\n");

for(int i = 0; i < 10; i++)
     printf("%lf ", hstC[i]);    
printf("\n");
 
// gettimeofday(&st,NULL);

cudaMalloc((Void **)&devA,memSz);
cudaMalloc((void **)&devB,memSz);
cudaMalloc((void **)&devC,memSz);

cublasSetVector(n2, sizeof(float), hstA, 1, devA, 1);
cublasSetVector(n2, sizeof(float), hstB, 1, devB, 1);

cublasHandle_t handle; 
cublasCreate(&handle);

cublasSgemm(    
        handle,
        CUBLAS_OP_N, 
        CUBLAS_OP_N, 
        num,    
        num,    
        num,    
        &alpha, 
        devA,   
        num,    
        devB,   
        num,    
        &beta,  
        devC,   
        num
);

int status;
status = cublasDestroy(handle);
cublasGetVector(n2, sizeof(float), devC, 1, hstC, 1);

for(int i = 0; i < 10; i++)
   printf("%lf ", hstC[i]);

printf("\n");

cudaFree(devA);
cudaFree(devB);
cudaFree(devC);

// gettimeofday(&et,NULL);

free(hstA);
free(hstB);
free(hstC);

}
