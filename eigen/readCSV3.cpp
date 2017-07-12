#include <iostream>
#include <fstream>
#include <eigen3/Eigen/Dense>

#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/SVD>

using namespace Eigen;

Eigen::MatrixXd readCSV(std::string file, int rows, int cols) {
  
  std::ifstream in(file.c_str());

  std::string line;

  int row = 0;
  int col = 0;

  // std::cout << rows << ";" << cols << std::endl;
  
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

int main(int argc, char *argv[])
{
  int i, j;
 
  Eigen::MatrixXd res = readCSV(argv[1], atoi(argv[2]), atoi(argv[3]));

  Eigen::MatrixXd res2 = res.rightCols(3);
  std::cout << res2 << std::endl;

  Eigen::MatrixXd res3 = readCSV(argv[4], atoi(argv[5]), atoi(argv[6]));

  Eigen::MatrixXd res4 = res3.rightCols(3);
  // std::cout << res4.rows() << std::endl;

  for(i=0; i< res4.rows(); i++)
    {
      std::cout << res4.row(i) << std::endl;
      
      for(j=0; j< res2.rows(); j++)
	{
	  std::cout << res2.row(j) << std::endl;
	}
       
    }
}

  
