#include <stdio.h>
#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/SVD>
#include <iostream>

using namespace Eigen;

typedef Matrix<float, 5, 6> Matrixf56;
typedef JacobiSVD<Matrixf56> SVDOfMatrixf56;

static Matrixf56 LowRankApprox(const SVDOfMatrixf56::SingularValuesType& sv,
                               const SVDOfMatrixf56::MatrixVType& v,
                               int rank) {
  Matrixf56 y = Matrixf56::Zero();
  for (int i = 0; i < rank && i < sv.size(); i++) {
    y(i, i) = sv(i);
  }
  return y * v.transpose();
}

float Cosine(const Matrixf56& c, int i, int j) {
  const VectorXf& col_i = c.col(i);
  const VectorXf& col_j = c.col(j);
  float a = col_i.transpose() * col_j;
  float b = col_i.norm() * col_j.norm();
  return a / b;
}

int main() {
  Matrixf56 c;
  c << 1, 0, 1, 0, 0, 0,
       0, 1, 0, 0, 0, 0,
       1, 1, 0, 0, 0, 0,
       1, 0, 0, 1, 1, 0,
       0, 0, 0, 1, 0, 1;

  std::cout  << c << std::endl;

  SVDOfMatrixf56 svd(c, Eigen::ComputeFullU | Eigen::ComputeFullV);
  const SVDOfMatrixf56::MatrixUType& u = svd.matrixU();
  const SVDOfMatrixf56::MatrixVType& v = svd.matrixV();
  const SVDOfMatrixf56::SingularValuesType& sv = svd.singularValues();
  std::cout << "singular values" << std::endl
            << sv << std::endl;
  std::cout << "matrix V" << std::endl << v << std::endl;
  std::cout << "matrix U" << std::endl << u << std::endl;

  Matrixf56 c_2 = LowRankApprox(sv, v, 2);
  Matrixf56 c_3 = LowRankApprox(sv, v, 3);
  Matrixf56 c_4 = LowRankApprox(sv, v, 4);
  std::cout << "c_3 = " << std::endl << c_3 << std::endl;
  std::cout << "cosine(0, 1) = " << std::endl << Cosine(c_3, 0, 1) << std::endl;

  printf("     c        c_4      c_3       c_2 \n");
  for (int i = 0; i < c_3.row(0).size(); i++) {
    printf("%d %5f %5f %5f %5f\n", i, Cosine(c, 0, i), Cosine(c_4, 0, i), Cosine(c_3, 0, i), Cosine(c_2, 0, i));
  }
  return 0;
}
