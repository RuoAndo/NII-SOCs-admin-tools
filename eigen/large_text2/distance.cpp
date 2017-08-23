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
  int i, j, k;
  int distance_tmp = 100000;
 
  Eigen::MatrixXd centroid = readCSV(argv[1], atoi(argv[2]), atoi(argv[3]));
  std::cout << centroid << std::endl;

  Eigen::MatrixXd sessiond = readCSV(argv[4], atoi(argv[5]), atoi(argv[6]));
  // std::cout << sessiond << std::endl;

  for(i=0;i<sessiond.rows();i++)
    {
	  Eigen::MatrixXd sessiondd = sessiond.row(i).rightCols(3);

	  for(j=0;j<centroid.rows();j++)
	    {
	    Eigen::MatrixXd centroidd = centroid.row(j).rightCols(3);
            Eigen::VectorXd distancev = (sessiondd - centroidd).rowwise().norm
();        
	    std::cout << "distance:" << distancev(0) << std::endl;
	    }	    
    }

}

  
