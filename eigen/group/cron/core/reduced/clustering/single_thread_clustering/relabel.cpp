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
#define CLUSTER_NUM 40

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

    double distance_tmp = 1000000; 

    string fname = std::to_string(targ->id);
    string fname_label = std::to_string(targ->id) + ".lbl";      

    /*
    string fname = std::to_string(targ->id);
    string fname_label = std::to_string(targ->id) + ".relabeled";
    */

    // std::cout << "reading " << fname << std::endl;
    
    Eigen::MatrixXd res = readCSV(fname, targ->rows,targ->columns);
    Eigen::MatrixXd res_label= readCSV(fname_label, targ->rows,targ->columns);
    Eigen::MatrixXd res2 = res.rightCols(3);
    Eigen::MatrixXd res3 = res.rightCols(5);

    // 0,2.23391e+09,2.88497e+09,66,0,2
    std::string ofname = std::to_string(targ->id) + ".rlbl";
      
    ofstream outputfile(ofname);
    
    for(i=0; i< res2.rows(); i++)
	{

	  counter = 0;
	  for(j=0; j < avg.rows(); j++)
	    {
	      Eigen::VectorXd distance = (res2.row(i) - avg.row(j)).rowwise().norm();

	      if(distance(0) < distance_tmp)
		{
		  std::cout << "THREAD:" << targ->id << ":distance:" << distance(0) << "->" << j << std::endl;
		  distance_tmp = distance(0);
		  counter = j;
		}
	      
	    }

	  outputfile << counter << endl;
	  // outputfile << counter << ",";
	    /*
	  for(k=0;k<res3.row(i).cols()-1 ;k++)
	    outputfile << res3.row(i).col(k) << ","; 

	  outputfile << res3.row(i).col(k);
	  outputfile << std::endl;
	  cluster_no[counter]++;  
	    */
	}

      outputfile.close();

      /*
      for(i = 0; i < CLUSTER_NUM; i++)
	std::cout << "CLUSTER:" << i << ":" << cluster_no[i] << std::endl; 
      */

    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i;

    /* クラスタ初期化 */
    for(i = 0; i < CLUSTER_NUM; i++)
      cluster_no[i] = 0; 

    /* 始めに重心を取り込む */
    Eigen::MatrixXd restmp = readCSV(argv[1], atoi(argv[2]), atoi(argv[3]));
    avg = restmp.rightCols(3);
    std::cout << avg << std::endl;      
    std::cout << avg.rows() << std::endl;      

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        targ[i].rows = atoi(argv[4]);
	targ[i].columns = atoi(argv[5]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }
    
    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);
}
