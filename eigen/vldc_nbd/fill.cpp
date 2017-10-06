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

#define THREAD_NUM 20
#define CLUSTER_NUM 10
#define ITEM_NUM 3

static int cluster_no[CLUSTER_NUM];
Eigen::VectorXd avg(3);

using namespace Eigen;
using namespace std;

typedef struct _thread_arg {
  int id;
  int rows;
  int columns;
} thread_arg_t;

typedef struct _result {
  double distance;
  double items[ITEM_NUM];
  pthread_mutex_t mutex;    
} result_t;
result_t result;

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

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int id;
    int i,j;
    double distance_tmp = 0;

    srand((unsigned int)time(NULL));

    id = targ->id;
    // std::cout << avg << std::endl;

    // string fname_labeled = std::to_string(targ->id) + ".labeled";
    string fname = std::to_string(targ->id);

    // std::cout << "reading " << fname << "..." << std::endl;
    
    Eigen::MatrixXd res = readCSV(fname, targ->rows,targ->columns);
    Eigen::MatrixXd res2 = res.rightCols(3);
    double my_items[ITEM_NUM];
    
    for(i=0; i< res2.rows(); i++)
	{
	  if((rand()*1000) % 100 > 3) 
	    {
	      Eigen::VectorXd res2vec = res2.row(i);
	      Eigen::VectorXd distance = (res2vec - avg).colwise().squaredNorm();
	  
	      if(distance(0) > distance_tmp)
		{
		  distance_tmp = distance(0);
		  my_items[0] = res2vec(0);
		  my_items[1] = res2vec(1);
		  my_items[2] = res2vec(2);
		}
	    }
	}

    pthread_mutex_lock(&result.mutex);
    if(distance_tmp > result.distance) {
            // std::cout << "updated:" << distance_tmp << std::endl;
            result.distance = distance_tmp;

	    int x = rand() % 201 - 100;
	    result.items[0] = my_items[0] + (my_items[0] / x);
	    x = rand() % 201 - 100;
	    result.items[1] = my_items[1] + (my_items[1] / x);
	    result.items[2] = my_items[2];
	    
    }
    pthread_mutex_unlock(&result.mutex);

    /*
    std::cout << distance_tmp << "," << point_max_distance << std::endl;
    */

    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i,j;

    /* ˆ—ŠJŽn */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;

	for (j = 0; j < ITEM_NUM; j++) {
	  // std::cout << i << ":" << atoi(argv[j]) << std::endl;
	  avg(j) = atof(argv[j+1]);
	}

        targ[i].rows = atoi(argv[4]);
	targ[i].columns = atoi(argv[5]);

        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);

    }

    /*
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        targ[i].rows = atoi(argv[4]);
	targ[i].columns = atoi(argv[5]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }
    */    

    /* I—¹‚ð‘Ò‚Â */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    /*
    std::cout << "done" << std::endl;
    std::cout << "distance:" << result.distance << std::endl;
    std::cout << "0:" << result.items[0] << std::endl;
    std::cout << "1:" << result.items[1] << std::endl;
    std::cout << "2:" << result.items[2] << std::endl;
    */

    std::cout << result.items[0] << "," << result.items[1] << "," << result.items[2] << std::endl; 
}
