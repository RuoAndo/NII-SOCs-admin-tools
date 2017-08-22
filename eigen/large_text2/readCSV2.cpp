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
  // std::cout << res << std::endl;

  // Eigen::MatrixXd res3 = res.rightCols(5);

  /*
  for(k=0;k<res.row(0).cols();k++)
	    outputfile << res3.row(i).col(k) << ","; 
  */

  std::cout << res << std::endl;
  std::cout << "#######" << std::endl;
  // std::cout << res.topRows(2) << std::endl;

  for(i=0;i<res.rows();i++)
    {
      std::cout << res.leftCols(1).row(i) << std::endl;
     
      j = res.leftCols(1).row(i)[0];
      
      if(j == 0)
	{
	  std::cout << res.row(i).rightCols(6) << std::endl;
	}

    }
}

  
