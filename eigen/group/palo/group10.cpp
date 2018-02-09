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

typedef struct _result2 {
  map<int, vector<string>> alert_name;
  pthread_mutex_t mutex;
} result2_t;
result2_t result2;


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

void thread_func1(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;

    int counter = 0;
    int counter2 = 0;

    int map_counter = 0;
    
    string src;
    string dst;
    string alert;
    
    unsigned int t, travdirtime;  
    
    map<string, string> myAddrPair;
    map<int, int> myBytePair;

    pthread_mutex_lock(&result.mutex);    
    myAddrPair = result.m;
    pthread_mutex_unlock(&result.mutex);
        
    string fname = std::to_string(targ->id);
    ifstream ifs(fname);

    start_timer(&t);   

    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;

      while(getline(stream,token,',')){

	if(counter==8)
	  {
	    src = token;
	  }
	if(counter==19)
	  {
	    dst = token;
	  }
	if(counter==12)
	  {
	    alert = token;
	  }
	
        counter = counter + 1;
      }
      
      map<string, string>::iterator itr;

      map_counter = 0;  
      for (itr = myAddrPair.begin(); itr != myAddrPair.end(); itr++)
	{
	  if(src == itr->first && dst == itr->second) {
	    
	    pthread_mutex_lock(&result2.mutex);
	    result2.alert_name[map_counter].push_back(alert);
	    pthread_mutex_unlock(&result2.mutex);

	  } // if(src == itr->first && dst == itr->second) {

	  map_counter++;	  
      }
      
    } // while(getline(ifs,str)){

    std::cout << "FUNC1:thread ID: " << targ->id << " - done." << std::endl; 
    
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int counter = 0;
    int counter2 = 0;
    int flag = 0;
    
    int i;

    std::vector<string> alerts;
    
    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, (void*)thread_func_IP, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    std::cout << "map size() is " << result.m.size() << std::endl; 

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, (void*)thread_func1, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    map<int, vector<string>>::iterator itr5;
    map<string, string>::iterator itr;

    counter = 0;
    flag = 0;
    for (itr = result.m.begin(); itr != result.m.end(); itr++)
      {
	std::cout << itr->first << "," << itr->second << ",";

	// std::cout << "size:" << result2.alert_name[counter].size() << std::endl;
	sort(result2.alert_name[counter].begin(), result2.alert_name[counter].end());
	result2.alert_name[counter].erase( unique(result2.alert_name[counter].begin(), result2.alert_name[counter].end()), result2.alert_name[counter].end() );
	// std::cout << "size2:" << result2.alert_name[counter].size() << std::endl;


	std::cout << "(" << (int)result2.alert_name[counter].size() << "), ";
        for(int i = 0; i < (int)result2.alert_name[counter].size(); ++i)
	  {
	    std::cout << result2.alert_name[counter][i] << ",";
	  }

	std::cout << std::endl;
	counter++;
      }
    
}
