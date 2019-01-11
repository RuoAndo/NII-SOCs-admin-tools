#include "../common/common.h"
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "cublas_v2.h"

#include <iostream>
#include <fstream>

using namespace std;

/*
 * Generate a vector of length N with random single-precision floating-point
 * values between 0 and 100.
 */
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

__global__ void incrementTest(float *X, const int N)
{
    int i = threadIdx.x;
    X[i] = X[i] + 1;
}

// step1: X = (A * X0);
__global__ void F_1_X_A_X0(float *A, float *X0, float *X, const int N)
{
    // int i = blockIdx.x * blockDim.x + threadIdx.x;
    int i = threadIdx.x;
    X[i] = A[i] * X0[i];
}

// step2: P = (A * P0 * A.transpose()) + Q;
// F_2_P_A_P0_Q<<<grid, block>>>(dA, dP, dQ, dP, 1);
__global__ void F_2_P_A_P0_Q(float *P, float *A, float *P0, float *Q, const int N)
{
    // int i = blockIdx.x * blockDim.x + threadIdx.x;
    int i = threadIdx.x;
    P[i] = A[i] * P0[i] + Q[i];
    // P[i] = 5; // P[i] + 1;
}

// step3: K = ( P * H.transpose() ) * ( H * P * H.transpose() + R).inverse();
__global__ void F_3_K_P_H_R(float *P, float *H, float *R, float *K, const int N)
{
    // int i = blockIdx.x * blockDim.x + threadIdx.x;
    int i = threadIdx.x;
    K[i] = 1/P[i] * H[i] * (1/P[i] + R[i]);
}

// step4: X = X + K*(Z - H * X);
__global__ void F_4_X_K_Z_H(float *K, float *Z, float *H, float *X, const int N)
{
    // int i = blockIdx.x * blockDim.x + threadIdx.x;
    int i = threadIdx.x;
    X[i] = X[i] + K[i] * (Z[i] - H[i] * X[i]);
}

// step5: P = (I - K * H) * P;
__global__ void F_5_I_K_H_P(float *I, float *K, float *H, float *P, float *out_5_P, const int N)
{
    int i = threadIdx.x;
    out_5_P[i] = (I[i] - K[i]) * P[i];
    //P2[i] = 4.8; // K[i]; // * H[i]);
}

int main(int argc, char **argv)
{

    /* Fixed Matrix */
    /*
    MatrixXf A; //System dynamics matrix
    MatrixXf B; //Control matrix 
    MatrixXf H; //Mesaurement Adaptation matrix
    MatrixXf Q; //Process Noise Covariance matrix
    MatrixXf R; //Measurement Noise Covariance matrix
    MatrixXf I; //Identity matrix
    */

    /* Variable Matrix */
    /*
    VectorXf X; //(Current) State vector
    MatrixXf P; //State Covariance
    MatrixXf K; //Kalman Gain matrix
    */

    /* Inizial Value */
    /*
    VectorXf X0; //Initial State vector
    MatrixXf P0; //Initial State Covariance matrix
    */
    
   /*
    void KalmanFilter::predict(void){
    	 X = (A * X0);
  	 P = (A * P0 * A.transpose()) + Q;
    }
    */

    float alpha = 1.0f;
    float beta = 1.0f;

    cublasHandle_t handle = 0;

    // VectorXf X; //Initial State vector
    float *X = 0;
    float *dX = 0;
    
    // MatrixXf A; //System dynamics matrix
    float *A = 0;
    float *dA = 0;

    // VectorXf X0; //Initial State vector
    float *X0 = 0;
    float *dX0 = 0;

    // MatrixXf P0; //Initial State Covariance matrix
    float *P = 0;
    float *dP = 0;

    // MatrixXf Q; //Process Noise Covariance matrix
    float *Q = 0;
    float *dQ = 0;

    // MatrixXf H; //Mesaurement Adaptation matrix
    float *H = 0;
    float *dH = 0;

    // MatrixXf P; //State Covariance
    float *P0 = 0;
    float *dP0 = 0;

    float *out_5_P = 0;
    float *dout_5_P = 0;

    // MatrixXf I; //State Covariance
    float *I = 0;
    float *dI = 0;

    float *K = 0;
    float *dK = 0;

    float *R = 0;
    float *dR = 0;

    float *Z = 0;
    float *dZ = 0;

    size_t nBytes = 1 * sizeof(float);
    X = (float *)malloc(nBytes);
    X0 = (float *)malloc(nBytes);
    A = (float *)malloc(nBytes);
    H = (float *)malloc(nBytes);
    P = (float *)malloc(nBytes);
    out_5_P = (float *)malloc(nBytes);
    P0 = (float *)malloc(nBytes);
    Q = (float *)malloc(nBytes);
    I = (float *)malloc(nBytes);
    R = (float *)malloc(nBytes);
    K = (float *)malloc(nBytes);
    Z = (float *)malloc(nBytes);

    X[0] = 1.0;
    X0[0] = 1.0;
    A[0] = 0.8;
    H[0] = 1.0;
    Q[0] = 1.0;
    I[0] = 1.0;
    P[0] = 1.0;
    P0[0] = 1.0;
    
    out_5_P[0] = 1.0;

    R[0] = 1.0;
    K[0] = 1.0;
    Z[0] = 1.0;
    
    CHECK(cudaMalloc((void **)&dX, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dX0, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dA, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dP, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dP0, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dQ, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dH, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dK, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dR, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dZ, sizeof(float) * 1));
    CHECK(cudaMalloc((void **)&dI, sizeof(float) * 1));

    CHECK(cudaMalloc((void **)&dout_5_P, sizeof(float) * 1));

    cudaMemcpy(dX, X, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dX0, X0, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dA, A, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dP, P, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dP, P0, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dQ, Q, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dH, H, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dK, K, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dR, R, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dZ, Z, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dI, I, nBytes, cudaMemcpyHostToDevice);

    cudaMemcpy(dout_5_P, out_5_P, nBytes, cudaMemcpyHostToDevice);

    dim3 grid = 1;
    dim3 block = 1;

    /*
    cudaMemcpy(dX, X, nBytes, cudaMemcpyDeviceToHost);
    for(int i=0; i<4; i++)
    {
    	cudaMemcpy(dX, X, nBytes, cudaMemcpyHostToDevice);
	incrementTest<<<grid, block>>>(dX, 1);
	cudaMemcpy(X, dX, nBytes, cudaMemcpyDeviceToHost);
    	printf("(i)X:%f \n", %d, X[0]);
    }
    */

    for(int i=0; i < 4; i++)
    {

    cudaMemcpy(dA, A, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dX, X, nBytes, cudaMemcpyHostToDevice);
    F_1_X_A_X0<<<grid, block>>>(dA, dX, dX, 1);
    cudaMemcpy(X, dX, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(A, dA, nBytes, cudaMemcpyDeviceToHost);
    printf("X:%f \n", X[0]);

    printf("STEP2B: P0:%f P:%f \n", P0[0],P[0]);
    cudaMemcpy(dP, P, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dA, A, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dP0, P0, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dQ, Q, nBytes, cudaMemcpyHostToDevice);
    F_2_P_A_P0_Q<<<grid, block>>>(dP, dA, dP0, dQ, 1);
    cudaMemcpy(P, dP, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(A, dA, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(P0, dP0, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(Q, dQ, nBytes, cudaMemcpyDeviceToHost);
    printf("STEP2A: P0:%f P:%f \n", P0[0],P[0]);

    /*
    void KalmanFilter::correct ( VectorXf Z ) {
    	 K = ( P * H.transpose() ) * ( H * P * H.transpose() + R).inverse();
      	 X = X + K*(Z - H * X);
	 P = (I - K * H) * P;
  	 X0 = X;
  	 P0 = P;	
	 }
    */

    Z[0] = 10;
    
    cudaMemcpy(dK, K, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dP, P, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dH, H, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dR, R, nBytes, cudaMemcpyHostToDevice);
    // __global__ void F_3_K_P_H_R(float *P, float *H, float *R, float *K, const int N)
    F_3_K_P_H_R<<<grid, block>>>(dP, dH, dR, dK, 1);
    cudaMemcpy(K, dK, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(P, dP, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(H, dH, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(R, dR, nBytes, cudaMemcpyDeviceToHost);
    printf("K:%f \n", K[0]);

    cudaMemcpy(dK, K, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dZ, Z, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dH, H, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dX, X, nBytes, cudaMemcpyHostToDevice);
    F_4_X_K_Z_H<<<grid, block>>>(dX, dK, dZ, dH, 1);
    // printf("Execution configure <<<%d, %d>>>\n", grid.x, block.x);
    cudaMemcpy(K, dK, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(Z, dZ, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(H, dH, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(X, dX, nBytes, cudaMemcpyDeviceToHost);    
    printf("X:%f \n", X[0]);



    printf("STEP5:K:%f \n", K[0]);
    printf("STEP5:P2:%f \n", out_5_P[0]);
    cudaMemcpy(dI, I, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dK, K, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dH, H, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dP, P, nBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dout_5_P, out_5_P, nBytes, cudaMemcpyHostToDevice);
    // __global__ void F_5_I_K_H_P(float *I, float *K, float *H, float *P, const int N)
    F_5_I_K_H_P<<<grid, block>>>(dI, dK, dH, dP, dout_5_P, 1);
    cudaMemcpy(I, dI, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(K, dK, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(H, dH, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(P, dP, nBytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(out_5_P, dout_5_P, nBytes, cudaMemcpyDeviceToHost);

    // printf("STEP5:P:%f \n", P[0]);
    printf("STEP5:dout_5_P:%f \n", out_5_P[0]);

    X0[0] = X[0];
    P0[0] = out_5_P[0];
    }
    
    return 0;
}
