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

#include <random>

#define THREAD_NUM 20
#define CLUSTER_NUM 10

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

typedef struct _result {
  int cluster_no[CLUSTER_NUM];
  
  long item3_sum[CLUSTER_NUM];
  long item4_sum[CLUSTER_NUM];
  long item5_sum[CLUSTER_NUM];
  
  pthread_mutex_t mutex;    
} result_t;
result_t result;

typedef struct _thread_arg {
    int id;
    int rows;
    int columns;
} thread_arg_t;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int label = 0;
    long tmpNo;
    int my_cluster_no[CLUSTER_NUM];
    long my_item3_sum = 0; 
    long my_item4_sum = 0;
    long my_item5_sum = 0;
    
    double distance_tmp = 1000000; 
    
    string fname = std::to_string(targ->id) + ".labeled";

    for(i=0;i<CLUSTER_NUM;i++)
      my_cluster_no[i]=0;
    
    /*
        targ[i].id = i;
        targ[i].rows = atoi(argv[4]);
	targ[i].columns = atoi(argv[5]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    */

    Eigen::MatrixXd res = readCSV(fname, targ->rows,targ->columns);
    Eigen::MatrixXd res2 = res.leftCols(1);
    Eigen::MatrixXd res3 = res.leftCols(6);
    
    // for(i=0; i< res2.rows(); i++)
    for(i=0; i< res2.rows(); i++)
      {
	tmpNo = res2.row(i).col(0)(0);
	my_cluster_no[tmpNo]++;
	
	my_item3_sum += res3.row(i).col(3)(0);
	my_item4_sum += res3.row(i).col(4)(0);
	my_item5_sum += res3.row(i).col(5)(0);
      }

    /*
    for(i=0; i< CLUSTER_NUM; i++)
      {
	std::cout << my_cluster_no[i] << std::endl;
      }
    */    

    pthread_mutex_lock(&result.mutex);
      for(i=0; i<CLUSTER_NUM; i++)
      {
	result.cluster_no[i] += my_cluster_no[i];
      }

      	result.item3_sum[targ->id] = my_item3_sum;
	result.item4_sum[targ->id] = my_item4_sum;
	result.item5_sum[targ->id] = my_item5_sum;
      
      /*
      	result.item3_sum += my_item3_sum;
	result.item4_sum += my_item4_sum;
	result.item5_sum += my_item5_sum;
      */
      
    pthread_mutex_unlock(&result.mutex);
    
    /*
    std::string ofname = fname + ".labeled";      
    ofstream outputfile(ofname);

    std::random_device rnd;
    */

    /*
    for (int i = 0; i < 10; ++i) {
      tmp = rnd() % 10;
      std::cout << tmp << "\n";
    }
    */

    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i;
    long sum3;
    long sum4;
    long sum5;

    /* ˆ—ŠJŽn */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        targ[i].rows = atoi(argv[1]);
	targ[i].columns = atoi(argv[2]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }

    /* I—¹‚ð‘Ò‚Â */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);
    
    std::cout << "CLUSTER:" << endl;
    
    for(i=0; i<CLUSTER_NUM; i++)
      {
	std::cout << result.cluster_no[i] << endl;
      }

    std::cout << "FILE:" << endl;

    sum3 = 0;
    sum4 = 0;
    sum5 = 0;
    
    for(i=0; i<THREAD_NUM; i++)
      {
	sum3 = sum3 + result.item3_sum[i];
	sum4 = sum4 + result.item4_sum[i];
        sum5 = sum5 + result.item5_sum[i];
      	// std::cout << result.item3_sum[i] << endl;
      }
    
    std::cout << sum3 << endl;
    std::cout << sum4 << endl;
    std::cout << sum5 << endl;
    
}

