#include "mulmat.hpp"
#include <cstdlib>
#include <iostream>
#include <omp.h>

MulMat::MulMat(long m, long n, long k, float a, float b) {
    M = m; N = n; K = k;
    LDA = K; LDB = N; LDC = N;
    alpha = a; beta = b;
}

MulMat::~MulMat() {
}

bool MulMat::initialize() {
    A = (float*)malloc(sizeof(float) * M*K);
    B = (float*)malloc(sizeof(float) * K*N);
    C = (float*)malloc(sizeof(float) * M*N);
    if (A == NULL || B == NULL || C == NULL) {
        return false;
    }
#pragma omp parallel for simd
    for (long i = 0; i < M; i++) {
        for (long j = 0; j < LDA; j++) {
            A[i*LDA + j] = 0.0;
        }
    }
#pragma omp parallel for simd
    for (long i = 0; i < K; i++) {
        for (long j = 0; j < LDB; j++) {
            B[i*LDB + j] = 0.0;
        }
    }
#pragma omp parallel for simd
    for (long i = 0; i < M; i++) {
        for (long j = 0; j < LDC; j++) {
            C[i*LDC + j] = 0.0;
        }
    }
    return true;
}

void MulMat::multiply() {
    cblas_sgemm(CblasRowMajor,CblasNoTrans,CblasNoTrans,M,N,K,alpha,A,LDA,B,LDB,beta,C,LDC);
}

void MulMat::memoryFree() {
    free(A);
    free(B);
    free(C);
}
