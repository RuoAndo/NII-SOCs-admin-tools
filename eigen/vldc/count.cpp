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
#define CLUSTER_NUM 20
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

    // string fname_label = "/dev/vldc_label_" + std::to_string(targ->id);
    string fname_label = "vldc_label_" + std::to_string(targ->id);      
    
    Eigen::MatrixXd res_label= readCSV(fname_label, targ->rows,targ->columns);
    
    for(i=0; i< res_label.rows(); i++)
	{
	  std::cout << res_label.row(i)(0) << std::endl;
	}

    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i;

    /* �N���X�^������ */
    for(i = 0; i < CLUSTER_NUM; i++)
      cluster_no[i] = 0; 

    /* �n�߂ɏd�S����荞�� */
    Eigen::MatrixXd restmp = readCSV(argv[1], atoi(argv[2]), atoi(argv[3]));
    avg = restmp.rightCols(3);
    std::cout << avg << std::endl;      
    std::cout << avg.rows() << std::endl;      

    /* �����J�n */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        targ[i].rows = atoi(argv[4]);
	targ[i].columns = atoi(argv[5]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }
    
    /* �I����҂� */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);
}
