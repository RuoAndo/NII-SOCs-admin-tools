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

#define THREAD_NUM 2

#define N_LINES 100000
#define N_SPLIT_LINES 1000

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

/* dataNo(counter), bytes */
typedef struct _result2 {
  map<int, int> m;
  pthread_mutex_t mutex;
} result2_t;
result2_t result2;

void thread_func0(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int label = 0;
    unsigned int key = 0;
    unsigned int value = 0;
    int counter = 0;
    int counter2 = 0;
    
    string src;
    string dst;
    int bytes;

    unsigned int t, travdirtime;  
    
    map<string, string> myAddrPair;

    std::cout << "FUNC0:thread ID: " << targ->id << " - start." << std::endl; 
    
    string fname = std::to_string(targ->id);
    ifstream ifs(fname);
    
    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;
      while(getline(stream,token,',')){
	// std::cout<< token << "(" << counter << "),";

	if(counter==7)
	  src = token;

	if(counter==9)
	  dst = token;
      
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
    int label = 0;
    unsigned int key = 0;
    unsigned int value = 0;
    int counter = 0;
    int counter2 = 0;

    int map_counter = 0;
    
    string src;
    string dst;
    int bytes;

    int byte_sum_tmp = 0;

    unsigned int t, travdirtime;  
    
    map<string, string> myAddrPair;
    map<int, int> myBytePair;

    pthread_mutex_lock(&result.mutex);    
    myAddrPair = result.m;
    pthread_mutex_unlock(&result.mutex);

    /*
    std::cout << "map size() is " << myAddrPair.size() << std::endl;
    */

    string fname = std::to_string(targ->id);
    ifstream ifs(fname);

    start_timer(&t);   

    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;

      while(getline(stream,token,',')){

	if(counter==7)
	  {
	    src = token;
	  }
	if(counter==9)
	  {
	    dst = token;
	  }
	if(counter==25)
	  {
	    bytes =  std::atoi(token.c_str());
	  }
	
        counter = counter + 1;
      }
      
      map<string, string>::iterator itr;

      // myAddrPair = result.m;
      
      for (itr = myAddrPair.begin(); itr != myAddrPair.end(); itr++)
	{
	  if(src == itr->first && dst == itr->second) {

	    myBytePair.insert(pair<int, int>(map_counter,bytes)); 

	    pthread_mutex_lock(&result2.mutex);
	    
	    byte_sum_tmp = result2.m[map_counter];
	    byte_sum_tmp = byte_sum_tmp + bytes;
	    result2.m[map_counter] = byte_sum_tmp;

	    // std::cout << "MACTH:" << map_counter << ":" << byte_sum_tmp << ":" << bytes << std::endl;
	    
	    // result2.m.insert(pair<int, int>(map_counter,byte_sum_tmp));   

	    // std::cout << "MACTH2:" << result2.m[map_counter] << std::endl;
	    
	    /*
            map<int, int>::iterator p;
	    p = result2.m.find(map_counter);

	    if(p != result2.m.end())
	      {
		byte_sum_tmp = p->second;
		byte_sum_tmp = byte_sum_tmp + bytes;
		result2.m.insert(pair<int, int>(map_counter,byte_sum_tmp));   
	      }
	    */
	    
	    pthread_mutex_unlock(&result2.mutex);
	    
	  } // if(src == itr->first && dst == itr->second) {

	  map_counter++;
	  
      }

      if(counter2 % N_SPLIT_LINES ==0)
	{
	  std::cout << "thread:" << targ->id << ": " << counter2/N_SPLIT_LINES << "% - done." << std::endl;

	  travdirtime = stop_timer(&t);
	  print_timer(travdirtime);      

	  start_timer(&t);   
	}

      counter2 = counter2 + 1;
      
    } // while(getline(ifs,str)){

    /*
    map<int, int>::iterator itr2;
    std::vector<int> v;

    counter = 0;

    for (itr2 = myBytePair.begin(); itr2 != myBytePair.end(); itr2++)
      {
	v.push_back((unsigned int)itr2->second);

	if(counter==10)
	  break;

	counter = counter + 1;
      }                    

    map<string, string>::iterator itr;

    counter = 0;
    for (itr = result.m.begin(); itr != result.m.end(); itr++)
      {

	int last = v.back();
	v.pop_back();

	std::cout << itr->first << "," << itr->second << "," << last << std::endl;

	if(counter==10)
	  break;

	counter = counter + 1;
      }          
    */    

    std::cout << "FUNC1:thread ID: " << targ->id << " - done." << std::endl; 
    
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int counter = 0;
    
    int i;

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
	/* size of data */
        // targ[i].rows = atoi(argv[1]);
	// targ[i].columns = atoi(argv[2]);
        pthread_create(&handle[i], NULL, (void*)thread_func0, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    std::cout << "map size() is " << result.m.size() << std::endl; 

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
	/* size of data */
        // targ[i].rows = atoi(argv[1]);
	// targ[i].columns = atoi(argv[2]);
        pthread_create(&handle[i], NULL, (void*)thread_func1, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    // std::cout << "reduce" << std::endl;
    
    map<int, int>::iterator itr2;
    std::vector<int> v;

    counter = 0;

    for (itr2 = result2.m.begin(); itr2 != result2.m.end(); itr2++)
      {
	// std::cout << itr2->second << std::endl;
	
	v.push_back(itr2->second);

	if(counter==30)
	  break;

	counter = counter + 1;
      }                    

    map<string, string>::iterator itr;

    counter = 0;
    for (itr = result.m.begin(); itr != result.m.end(); itr++)
      {

	/*
	int last = v.back();
	v.pop_back();
	*/

	// std::cout << itr->first << "," << itr->second << "," << last << std::endl;
	std::cout << itr->first << "," << itr->second << "," << v[counter] << std::endl;
	// std::cout << itr->first << "," << itr->second << std::endl;

	if(counter==30)
	  break;

	counter = counter + 1;
      }
    
}
