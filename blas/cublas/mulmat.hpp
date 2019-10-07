#include <cblas.h>

class MulMat {
private:
    long M, N, K;
    float *A, *B, *C;
    float alpha, beta;
    long LDA, LDB, LDC;
public:
    MulMat(long m, long n, long k, float a, float b);
    ~MulMat();
    bool initialize();
    void multiply();
    void memoryFree();
    float* getA() { return A; }
    float* getB() { return B; }
    float* getC() { return C; }
};
