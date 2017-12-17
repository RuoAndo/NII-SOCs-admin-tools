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

#define THREAD_NUM 15
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

typedef struct _result {
  double distance[CLUSTER_NUM];  
  int threadID[CLUSTER_NUM];
  int line[CLUSTER_NUM];
  long sip[CLUSTER_NUM];
  long dip[CLUSTER_NUM];
  double item1[CLUSTER_NUM];
  double item2[CLUSTER_NUM];
  double item3[CLUSTER_NUM];
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
    int counter = 0;

    double distance_tmp = 0; 
    double distance_all_cluster = 0; 
    double counter_all = 0;
    double cluster_no = 0;

    string fname = std::to_string(targ->id);
    Eigen::MatrixXd res = readCSV(fname, targ->rows,targ->columns);
    Eigen::MatrixXd res2 = res.rightCols(3);

    counter_all = 0;
    cluster_no = 0;
    for(j=0; j < avg.rows(); j++)
         {
	   counter = 0;
	   distance_tmp = 10000000;
	   for(i=0; i < res.rows(); i++)
	     {
	      Eigen::VectorXd distance = (res2.row(i) - avg.row(j)).rowwise().norm();

	      // std::cout << distance(0) << std::endl;
	      if(distance(0) < distance_tmp)
		{
		  distance_tmp = distance(0);
		  counter = i;		  
		}
	    }

	   std::cout << "threadID:" << targ->id << ":clusterNo:" << j << ":line:" << counter << ":distance:" << distance_tmp << std::endl; 

	   pthread_mutex_lock(&result.mutex);

	   if(result.distance[j] > distance_tmp)
	     {
	       result.distance[j] = distance_tmp;
	       result.threadID[j] = (int)targ->id;
	       result.line[j] = counter;
	       result.sip[j] = res.row(counter).col(0)(0);
	       result.dip[j] = res.row(counter).col(1)(0);
	       result.item1[j] = res.row(counter).col(2)(0);
	       result.item2[j] = res.row(counter).col(3)(0);
	       result.item3[j] = res.row(counter).col(4)(0);
	     }
            
	   pthread_mutex_unlock(&result.mutex);
   
	 }

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

    for (i = 0; i < CLUSTER_NUM; i++) 
      result.distance[i] = 10000000000;

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

    for (i = 0; i < CLUSTER_NUM; i++) 
      {
	std::cout << "clusterNo:" << i << ":threadID:" << result.threadID[i] << ":line:" << result.line[i] << ":distance:" << result.distance[i] << ":sip:" << result.sip[i] << ":dip:" << result.dip[i] << ":1:" << result.item1[i] << ":2:" << result.item2[i] << ":3:" << result.item3[i] << std::endl;
      }
}
