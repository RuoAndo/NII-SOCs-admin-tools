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

#include "timer.h"

/* 1000 * 1,0000 */

#define THREAD_NUM 1

using namespace Eigen;
using namespace std;

map<string, string> m2;

typedef struct _thread_arg {
    int id;
} thread_arg_t;

/* srcIP, destIP */
typedef struct _result {
  vector<string> dstAddr;
  pthread_mutex_t mutex;
} result_t;
result_t result;

void thread_func0(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int counter = 0;
    int linecounter = 0;
    
    string src;
    string dst;

    unsigned int t, travdirtime;  
    
    map<string, string> myAddrPair;

    std::cout << "FUNC0:thread ID: " << targ->id << " - start." << std::endl; 

    string fname;
    fname = std::to_string(targ->id);

    ifstream ifs(fname);
    
    string str;

    linecounter = 0;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      
      counter = 0;

      // std::cout << str << std::endl;
      while(getline(stream,token,',')){
	
	// std::cout<< token << ":" << counter <<std::endl;

	if(counter==8 && linecounter > 0)
	  {
	    src = token;

	    pthread_mutex_lock(&result.mutex);	    
	    result.dstAddr.push_back(src);
	    pthread_mutex_unlock(&result.mutex);

	    // std::cout<< token << ":" << counter <<std::endl;
	  }
	    
	counter = counter + 1;
      }

      linecounter = linecounter + 1;
    }

    pthread_mutex_lock(&result.mutex);	    
    std::sort(result.dstAddr.begin(), result.dstAddr.end());
    result.dstAddr.erase(std::unique(result.dstAddr.begin(), result.dstAddr.end()), result.dstAddr.end());
    pthread_mutex_unlock(&result.mutex);
    
    std::cout << "FUNC1:thread ID: " << targ->id << " - done." << std::endl;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int counter = 0;
    
    int i;

    /* ˆ—ŠJŽn */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, (void*)thread_func0, (void*)&targ[i]);
    }

    /* I—¹‚ð‘Ò‚Â */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    std::cout << "map size() is " << result.dstAddr.size() << std::endl; 

    auto it = result.dstAddr.begin();
    
    for (int i = 0; i < result.dstAddr.size(); ++i) {
      // if (0 < i) std::cout << ", ";  
      std::cout << it[i] << std::endl;
    }
    
}
