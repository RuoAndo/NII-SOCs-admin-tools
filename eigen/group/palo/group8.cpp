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
#define THREAD_NUM 1

#define N_LINES 10000
#define N_PERCENT_LINES 100
#define N_DISPLAY 50

using namespace Eigen;
using namespace std;

map<string, string> m2;

typedef struct _thread_arg {
    int id;
} thread_arg_t;

/* srcIP, destIP */
typedef struct _result {
  map<string, string> m;
  pthread_mutex_t mutex;
} result_t;
result_t result;

void thread_func_IP(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int counter = 0;

    string src;
    string dst;
    
    unsigned int t, travdirtime;  
    
    map<string, string> myAddrPair;

    std::cout << "func_IP:thread ID: " << targ->id << " - start." << std::endl; 
    
    string fname = std::to_string(targ->id);
    ifstream ifs(fname);
    
    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);

      counter = 0;
      while(getline(stream,token,',')){

	if(counter==8)
	  src = token;

	if(counter==19)
	  dst = token;

	// std::cout << "item1:" << src << ":" << dst << std::endl;
	// std::cout << token << std::endl;
	
	counter = counter + 1;
      }

      // myAddrPair.insert(pair<string, string>(src,dst));

      pthread_mutex_lock(&result.mutex);
      result.m.insert(pair<string, string>(src,dst));
      pthread_mutex_unlock(&result.mutex);
      
    } // while(getline(ifs,str)){

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
        pthread_create(&handle[i], NULL, (void*)thread_func_IP, (void*)&targ[i]);
    }

    /* I—¹‚ð‘Ò‚Â */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    std::cout << "map size() is " << result.m.size() << std::endl; 

    map<string, string>::iterator itr;
    
    for (itr = result.m.begin(); itr != result.m.end(); itr++)
      {
	std::cout << itr->first << "," << itr->second << std::endl;
      }
    
}
