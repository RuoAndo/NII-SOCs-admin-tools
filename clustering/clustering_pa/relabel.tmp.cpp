#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <pthread.h>

#include <string>
#include <iostream>
#include <fstream>
#include <eigen3/Eigen/Dense>

#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/SVD>

#define THREAD_NUM 1
#define CLUSTER_NUM N

static int cluster_no[CLUSTER_NUM];

using namespace Eigen;
using namespace std;

Eigen::MatrixXd avg;

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

typedef struct _thread_arg {
    int id;
    int rows;
    int columns;
} thread_arg_t;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int counter = 0;

    string fname = std::to_string(targ->id);
    string fname_label = std::to_string(targ->id) + ".lbl";      
    
    Eigen::MatrixXd res = readCSV(fname, targ->rows,targ->columns);
    Eigen::MatrixXd res_label= readCSV(fname_label, targ->rows,targ->columns);
    Eigen::MatrixXd res2 = res.rightCols(N);
    Eigen::MatrixXd res3 = res.rightCols(N);

    std::string ofname = std::to_string(targ->id) + ".rlbl";
      
    ofstream outputfile(ofname);

    // double distance_tmp = 1000000; 
    
    for(i=0; i< res2.rows(); i++)
	{
	  counter = 0;

	  std::vector<int> v(0, avg.rows());

	  for(j=0; j < avg.rows(); j++)
	    {
	      Eigen::VectorXd distance = (res2.row(i) - avg.row(j)).rowwise().norm();

	      // std::cout << "THREAD:" << targ->id << ":point" << i << ":distance:" << distance(0) << "->" << j << std::endl;
	      v.push_back(distance(0));
	    }

	  std::vector<int>::iterator iter = std::min_element(v.begin(), v.end());
	  int index = std::distance(v.begin(), iter);

	  // std::cout << "Index of min element: " << index << std::endl;
	  
	  outputfile << index << endl;
	}

    
      outputfile.close();

    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i;

    /* init  */
    for(i = 0; i < CLUSTER_NUM; i++)
      cluster_no[i] = 0; 

    /* reading centroid */
    Eigen::MatrixXd restmp = readCSV(argv[1], atoi(argv[2]), atoi(argv[3]));
    avg = restmp.rightCols(N);
    std::cout << avg << std::endl;      
    std::cout << avg.rows() << std::endl;      

    /* scatter */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        targ[i].rows = atoi(argv[4]);
	targ[i].columns = atoi(argv[5]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }
    
    /* join */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);
}
