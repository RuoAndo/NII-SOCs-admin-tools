# cblas_sgemm

<pre>
void cblas_sgemm(const enum CBLAS_ORDER __Order, const enum CBLAS_TRANSPOSE __TransA, const enum CBLAS_TRANSPOSE __TransB, const int __M, const int __N, const int __K, const float __alpha, const float *__A, const int __lda, const float *__B, const int __ldb, const float __beta, float *__C, const int __ldc);
</pre>

<pre>
Order: Specifies row-major (C) or column-major (Fortran) data ordering.

TransA: Specifies whether to transpose matrix A.

TransB: Specifies whether to transpose matrix B.

M: Number of rows in matrices A and C.

N: Number of columns in matrices B and C.

K: Number of columns in matrix A; number of rows in matrix B.

alpha: Scaling factor for the product of matrices A and B.

A: Matrix A.

lda: The size of the first dimention of matrix A; if you are passing a matrix A[m][n], the value should be m.

B: Matrix B.

ldb: The size of the first dimention of matrix B; if you are passing a matrix B[m][n], the value should be m.

beta: Scaling factor for matrix C.

C: Matrix C.

ldc: The size of the first dimention of matrix C; if you are passing a matrix C[m][n], the value should be m.
</pre>

<pre>
This function multiplies A * B and multiplies the resulting matrix by alpha. It then multiplies matrix C by beta. It stores the sum of these two products in matrix C.

Thus, it calculates either

C←αAB + βC

or

C←αBA + βC

with optional use of transposed forms of A, B, or both.
</pre>