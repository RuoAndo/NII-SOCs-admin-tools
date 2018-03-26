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

#include <list>
#include <vector>

#define THREAD_NUM 700
#define CLUSTER_NUM 20
#define PICKUP_DEPTH 10

static int cluster_no[CLUSTER_NUM];

using namespace Eigen;
using namespace std;

Eigen::MatrixXd avg;
// Eigen::MatrixXd restmp;

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
  // double distance[CLUSTER_NUM];
  // queue <double> distance[CLUSTER_NUM];
  list <double> distance[CLUSTER_NUM];
  list <int> threadID[CLUSTER_NUM];
  list <int> line[CLUSTER_NUM];
  list <long> sip[CLUSTER_NUM];
  list <long> dip[CLUSTER_NUM];
  list <double> item1[CLUSTER_NUM];
  list <double> item2[CLUSTER_NUM];
  list <double> item3[CLUSTER_NUM];
  
  /*
  int threadID[CLUSTER_NUM];
  int line[CLUSTER_NUM];
  long sip[CLUSTER_NUM];
  long dip[CLUSTER_NUM];
  double item1[CLUSTER_NUM];
  double item2[CLUSTER_NUM];
  double item3[CLUSTER_NUM];
  */
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
    int distance_flag = 0;
    
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

	   list<double>::iterator p = result.distance[j].begin();
	   
	   while(p != result.distance[j].end())
	     {
	       double p_tmp;
	       // p_tmp = std::stod(*p);
	       
	       if (*p > distance_tmp)
		 {
		   // std::cout << "p:" << *p << ":" << distance_tmp << ":" << result.distance[j].size() << std::endl;
		   distance_flag = 1;
		 }
	       
	       p++;
	     }

	   if(distance_flag==1)
	      {
		   result.distance[j].push_back(distance_tmp);
		   result.threadID[j].push_back((int)targ->id);
		   result.line[j].push_back(counter);
		   result.sip[j].push_back(res.row(counter).col(0)(0));
		   result.dip[j].push_back(res.row(counter).col(1)(0));
		   result.item1[j].push_back(res.row(counter).col(2)(0));
		   result.item2[j].push_back(res.row(counter).col(3)(0));
		   result.item3[j].push_back(res.row(counter).col(4)(0));
	      }
	   
	   if(result.distance[j].size() > PICKUP_DEPTH)
	      {
		   result.distance[j].pop_front();
		   result.threadID[j].pop_front();
		   result.line[j].pop_front();
		   result.sip[j].pop_front();
		   result.dip[j].pop_front();
		   result.item1[j].pop_front();
		   result.item2[j].pop_front();
		   result.item3[j].pop_front();
	      }

	   list<double>::iterator q = result.distance[j].begin();
	   while(q != result.distance[j].end())
	     {
	       std::cout << ":::" << *q << std::endl;
	       q++;
	     }
	   
	     /*
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
	     */

	   pthread_mutex_unlock(&result.mutex);
   
	 }

    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i,j;

    /* クラスタ初期化 */
    for(i = 0; i < CLUSTER_NUM; i++)
      cluster_no[i] = 0; 

    for (i = 0; i < CLUSTER_NUM; i++)
    	   result.distance[i].push_back(10000000000);

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
	vector<double> result_distance(result.distance[i].begin(), result.distance[i].end());
	vector<double> result_threadID(result.threadID[i].begin(), result.threadID[i].end());
	vector<double> result_line(result.line[i].begin(), result.line[i].end());
      	vector<double> result_sip(result.sip[i].begin(), result.sip[i].end());
	vector<double> result_dip(result.dip[i].begin(), result.dip[i].end());
	vector<double> result_item1(result.item1[i].begin(), result.item1[i].end());
	vector<double> result_item2(result.item2[i].begin(), result.item2[i].end());
	vector<double> result_item3(result.item3[i].begin(), result.item3[i].end());
	// std::cout << "clusterNo:" << i << ":distance:" << result.threadID[i] << std::endl;

	j=0;
	for (vector<double>::iterator it=result_distance.begin();  it !=result_distance.end(); it++) {
	  std::cout << "clusterNo:" << i << ":threadID:" << result_threadID[j] << ":line:" << result_line[j] << ":distance:" << result_distance[j] << ":sip:" << result_sip[j] << ":dip:" << result_dip[j] << ":ITEM1:" << result_item1[j] << ":ITEM2:" << result_item2[j] << ":ITEM3:" << result_item3[j] << std::endl;
	  j++;
	}
	
      }
}
