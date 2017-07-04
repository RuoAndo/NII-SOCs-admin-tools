#include <iostream>
#include <fstream>
#include <eigen3/Eigen/Dense>

#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/SVD>

using namespace Eigen;

/*
typedef Matrix<float, 100, 5> Matrixf1005;
typedef JacobiSVD<Matrixf1005> SVDOfMatrixf1005;
*/

Eigen::MatrixXd readCSV(std::string file, int rows, int cols) {
  
  std::ifstream in(file.c_str());

  std::string line;

  int row = 0;
  int col = 0;

  Eigen::MatrixXd res = Eigen::MatrixXd(rows, cols);

  if (in.is_open()) {

    while (std::getline(in, line)) {

      char *ptr = (char *) line.c_str();
      int len = line.length();

      col = 0;

      char *start = ptr;
      for (int i = 0; i < len; i++) {

	if (ptr[i] == ',') {
	  res(row, col++) = atof(start);
	  start = ptr + i + 1;
	}
      }
      res(row, col) = atof(start);

      row++;
    }

    in.close();
  }
  return res;
}

int main()
{
  int i, j;
  
  Eigen::MatrixXd res = readCSV("test-100",100,5);
  // std::cout << res << std::endl;
  
  JacobiSVD<Eigen::MatrixXd> svd(res, Eigen::ComputeFullU | Eigen::ComputeFullV);
  
  const JacobiSVD<Eigen::MatrixXd>::MatrixUType& u = svd.matrixU();
  const JacobiSVD<Eigen::MatrixXd>::MatrixVType& v = svd.matrixV();
  const JacobiSVD<Eigen::MatrixXd>::SingularValuesType& sv = svd.singularValues();
  /*
  std::cout << "singular values" << std::endl
            << sv << std::endl;  
  */  

  // std::cout << "matrix V" << std::endl << v << std::endl;
  // std::cout << "matrix U" << std::endl << u << std::endl;

  /*
  std::cout << "transpose" << std::endl;
  std::cout << v* v.transpose() << std::endl;
  */

  Eigen::MatrixXd y = MatrixXd::Zero(100,5);
  
  for (int i = 0; i < 2 && i < sv.size(); i++) {
    y(i, i) = sv(i);
  }

  Eigen::MatrixXd tr = y * v.transpose();
  /*
  std::cout << "transpose" << std::endl;
  std::cout << tr << std::endl;
  */
  
  Eigen::MatrixXd tr2 = tr.topRows(2);
  /*
  std::cout << tr2 << std::endl;
  */

  Eigen::MatrixXd out = res * tr2.transpose();
  std::cout << out << std::endl;
}

  
