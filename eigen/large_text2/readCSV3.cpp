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
 
  Eigen::MatrixXd res = readCSV(argv[1], atoi(argv[2]), atoi(argv[3]));
  Eigen::MatrixXd replaced;

  std::cout << res << std::endl;
  std::cout << "#######" << std::endl;
  // std::cout << res.topRows(2) << std::endl;

  for(i=0;i<res.rows();i++)
    {
      std::cout << res.leftCols(1).row(i) << std::endl;
     
      j = res.leftCols(1).row(i)[0];
      
      if(j == 0)
	{
	  Eigen::MatrixXd centroid = res.row(i).rightCols(3);
	  // std::cout << "centroid:" << centroid << std::endl;
          //Eigen::MatrixXd sessiond = res.rightCols(3);
	  // std::cout << res.row(i).rightCols(6) << std::endl;

	  Eigen::MatrixXd res2 = readCSV("1", 500000, 5);
	  distance_tmp = 100000000;

	  for(k=0; k< res2.rows(); k++)
	    {
	      Eigen::MatrixXd sessiond = res2.row(k).rightCols(3);
	      // std::cout << "sessiond:" << sessiond << std::endl;

	      Eigen::VectorXd distance = (sessiond - centroid).rowwise().norm();        
	      // std::cout << "distance:" << distance << std::endl;

	      if (distance(0) < distance_tmp)
		{
		  //std::cout << "distance:" << distance << std::endl;
		  //std::cout << res2.row(k) << std::endl;
		  replaced = res2.row(k);
		  distance_tmp = distance(0);
		}
	    }

	  // std::cout << res2.row(k) << std::endl;
	  std::cout << replaced << std::endl;

	  //std::cout << res2.rightCols(3) << std::endl;
	}

    }
}

  
