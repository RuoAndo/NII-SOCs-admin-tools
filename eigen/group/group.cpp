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
#include <map>

#define THREAD_NUM 1

using namespace Eigen;
using namespace std;

template<typename M>
M load_csv (const std::string & path) {
  std::ifstream indata;
  indata.open(path);
  std::string line;
  std::vector<double> values;
  uint rows = 0;
  while (std::getline(indata, line)) {
    std::stringstream lineStream(line);
    std::string cell;
    while (std::getline(lineStream, cell, ',')) {
      values.push_back(std::stod(cell));
    }
    ++rows;
  }
  return Map<const Matrix<typename M::Scalar, M::RowsAtCompileTime, M::ColsAtCompileTime, RowMajor>>(values.data(), rows, values.size()/rows);
}

Eigen::MatrixXi readCSV(std::string file, int rows, int cols) {
  
  std::ifstream in(file.c_str());

  std::string line;

  int row = 0;
  int col = 0;

  Eigen::MatrixXi res = Eigen::MatrixXi(rows, cols);

  if (in.is_open()) {

    while (std::getline(in, line)) {

      char *ptr = (char *) line.c_str();
      int len = line.length();

      col = 0;

      char *start = ptr;
      for (int i = 0; i < len; i++) {

	if (ptr[i] == ',') {
	  //cout << i << ":" << (unsigned int)atof(start) << endl;	  
	  res(row, col++) = atof(start);
	  start = ptr + i + 1;
	}
	
      }
      //cout << start << endl;
      res(row, col) = atof(start);

      row++;
    }

    in.close();
  }
  return res;
}

typedef struct _thread_arg {
    int id;
} thread_arg_t;

typedef struct _result {
  map<int, int> m;
  pthread_mutex_t mutex;
} result_t;
result_t result;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int label = 0;
    unsigned int key = 0;
    unsigned int value = 0;
    
    string fname = std::to_string(targ->id);
    
    // std::cout << "thread ID: " << targ->id << " - start." << std::endl;

    Eigen::MatrixXd res = load_csv<MatrixXd>(fname);
    
      // Eigen::MatrixXi res = readCSV(fname, targ->rows, targ->columns);
    
    for(i=0; i< res.rows(); i++)
	{

	  // std::cout << res.row(i) << std::endl;

	  key = res.row(i).col(0)(0);
	  value = res.row(i).col(1)(0);

	  pthread_mutex_lock(&result.mutex);
	  result.m.insert(pair<int, int>(key,value));
	  pthread_mutex_unlock(&result.mutex);
	  
	}

    // std::cout << "thread ID: " << targ->id << " - done." << std::endl;
      
    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];

    int i;

    /* ˆ—ŠJŽn */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
	/* size of data */
        // targ[i].rows = atoi(argv[1]);
	// targ[i].columns = atoi(argv[2]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }

    /* I—¹‚ð‘Ò‚Â */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    std::cout << "map size() is " << result.m.size() << std::endl;

    map<int, int>::iterator itr;

    /*
    for (itr = result.m.begin(); itr != result.m.end(); itr++)
      {
	std::cout << (unsigned int)itr->first << "," << (unsigned int)itr->second << std::endl;
      }
    */    

}
