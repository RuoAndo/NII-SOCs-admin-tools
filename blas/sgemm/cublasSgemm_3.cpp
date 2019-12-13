#include "cuda_runtime.h"
#include "cublas_v2.h"
#include <iostream>
#include <stdlib.h>

using namespace std;

int const A_ROW = 5;
int const A_COL = 6;
int const B_ROW = 6;
int const B_COL = 7;

int main()
{
  cublasStatus_t status;
  float *h_A,*h_B,*h_C;  
  h_A = (float*)malloc(sizeof(float)*A_ROW*A_COL); 
  h_B = (float*)malloc(sizeof(float)*B_ROW*B_COL);
  h_C = (float*)malloc(sizeof(float)*A_ROW*B_COL);

  for (int i=0; i<A_ROW*A_COL; i++) {
    h_A[i] = (float)(rand()%10+1);
  }
  for(int i=0;i<B_ROW*B_COL; i++) {
    h_B[i] = (float)(rand()%10+1);
  }

  cout << "A : row 5: col 6" << endl;
  for (int i=0; i<A_ROW*A_COL; i++){
    cout << h_A[i] << " ";
    if ((i+1)%A_COL == 0) cout << endl;
  }
  cout << endl;
  cout << "B : row 6: col 5" << endl;
  for (int i=0; i<B_ROW*B_COL; i++){
    cout << h_B[i] << " ";
    if ((i+1)%B_COL == 0) cout << endl;
  }
  cout << endl;

  float *d_A,*d_B,*d_C;  
  cudaMalloc((void**)&d_A,sizeof(float)*A_ROW*A_COL); 
  cudaMalloc((void**)&d_B,sizeof(float)*B_ROW*B_COL);
  cudaMalloc((void**)&d_C,sizeof(float)*A_ROW*B_COL);

  cublasHandle_t handle;
  cublasCreate(&handle);
  cudaMemcpy(d_A,h_A,sizeof(float)*A_ROW*A_COL,cudaMemcpyHostToDevice); 
  cudaMemcpy(d_B,h_B,sizeof(float)*B_ROW*B_COL,cudaMemcpyHostToDevice);

  struct timespec startTime, endTime, sleepTime;

  clock_gettime(CLOCK_REALTIME, &startTime);
  sleepTime.tv_sec = 0;
  sleepTime.tv_nsec = 123;
  
  float a = 1, b = 0;
  cublasSgemm(
          handle,
          CUBLAS_OP_T,   
          CUBLAS_OP_T,  
          A_ROW,        
          B_COL,        
          A_COL,        
          &a,           
          d_A,          
          A_COL,        
          d_B,          
          B_COL,        
          &b,           
          d_C,          
          A_ROW         
  );
  
  std::cout << "A*B :row 5:col 7" << std::endl;

  clock_gettime(CLOCK_REALTIME, &endTime);

  printf("[GPU] "); 
  if (endTime.tv_nsec < startTime.tv_nsec) {
    printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	   ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
  } else {
    printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec
	   ,endTime.tv_nsec - startTime.tv_nsec);
  }
  printf(" sec\n");
  
  cudaMemcpy(h_C,d_C,sizeof(float)*A_ROW*B_COL,cudaMemcpyDeviceToHost);
  for(int i=0;i<A_ROW*B_COL;++i) {
    std::cout<<h_C[i]<<" ";
    if((i+1)%B_COL==0) std::cout<<std::endl;
  }
  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);
  free(h_A);
  free(h_B);
  free(h_C);
  return 0;
}

