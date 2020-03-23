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
        // int r = rand();
        // double dr = (double)r;
	X[i] = (float)(rand() & 0xFF) / 100.0f; 
        // X[i] = (dr / rMax) * 100.0;
    }

    *outX = X;
}

int main(int argc, char *argv[])
{
   // timeval st,et;

   float *hstA,*hstB,*hstC;
   float *devA,*devB,*devC;

   float alpha = 1.0f;
   float beta = 0.0f;

   if (argc <= 1)
   {
	printf("usage: ./a.out MATRIX_SIZE \n");
   }
   
   int num = atoi(argv[1]);

   int n2 = num*num;
   size_t memSz = n2 * sizeof(float);

   hstA=(float*)malloc(memSz);
   hstB=(float*)malloc(memSz);
   hstC=(float*)malloc(memSz);

   /* insertion */

   srand((unsigned int)time(NULL));

   struct timespec startTime, endTime, sleepTime;

   printf("matrix size %d : %d \n", num, num);

   clock_gettime(CLOCK_REALTIME, &startTime);
   sleepTime.tv_sec = 0;
   sleepTime.tv_nsec = 123;

   generate_random_vector(memSz, &hstA);
   generate_random_vector(memSz, &hstB);
   generate_random_vector(memSz, &hstC);

   clock_gettime(CLOCK_REALTIME, &endTime);

   // printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
   // printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
   printf("generate_random_vector: ");
   if (endTime.tv_nsec < startTime.tv_nsec) {
     printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
   } else {
     printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
   }
   printf(" sec \n");
					    
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

   clock_gettime(CLOCK_REALTIME, &startTime);
   sleepTime.tv_sec = 0;
   sleepTime.tv_nsec = 123;

   cudaMalloc((void **)&devA,memSz);
   cudaMalloc((void **)&devB,memSz);
   cudaMalloc((void **)&devC,memSz);

   cublasSetVector(n2, sizeof(float), hstA, 1, devA, 1);
   cublasSetVector(n2, sizeof(float), hstB, 1, devB, 1);

   clock_gettime(CLOCK_REALTIME, &endTime);

   printf("Malloc and SetVector: ");
   if (endTime.tv_nsec < startTime.tv_nsec) {
     printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
   } else {
     printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
   }
   printf(" sec \n");

   cublasHandle_t handle; 
   cublasCreate(&handle);

   clock_gettime(CLOCK_REALTIME, &startTime);
   sleepTime.tv_sec = 0;
   sleepTime.tv_nsec = 123;

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

   clock_gettime(CLOCK_REALTIME, &endTime);

   // printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
   // printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
   printf("cublasSgemm: ");
   if (endTime.tv_nsec < startTime.tv_nsec) {
     printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
   } else {
     printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
   }
   printf(" sec \n");

   int status;
   status = cublasDestroy(handle);
   cublasGetVector(n2, sizeof(float), devC, 1, hstC, 1);

   for(int i = 0; i < 10; i++)
   	   printf("%lf ", hstC[i]);
   printf("\n");

   cudaFree(devA);
   cudaFree(devB);
   cudaFree(devC);

   free(hstA);
   free(hstB);
   free(hstC);

}
