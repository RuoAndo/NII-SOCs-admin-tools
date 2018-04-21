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

#define N_LINES 3000
#define N_PERCENT_LINES 30
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

/* dataNo(counter), bytes */
typedef struct _result2 {
  map<int, int> item1;
  map<int, int> item2;
  map<int, int> item3;
  map<int, int> item4;
  map<int, int> item5;
  map<int, int> item6;
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

    string fname;
    
    unsigned int t, travdirtime;  
    
    map<string, string> myAddrPair;

    std::cout << "FUNC0:thread ID: " << targ->id << " - start." << std::endl; 

    fname = std::to_string(targ->id);

    std::cout << "FUNC0:thread ID: " << fname << " - reading." << std::endl; 

    ifstream ifs(fname);
    
    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;
      while(getline(stream,token,',')){
	// std::cout<< token << "(" << counter << "),";

	if(counter==0)
	  src = token;

	if(counter==1)
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

    int item1 = 0;
    int item2 = 0;
    int item3 = 0;
    int item4 = 0;
    int item5 = 0;
    int item6 = 0;

    int item1_sum = 0;
    int item2_sum = 0;
    int item3_sum = 0;
    int item4_sum = 0;
    int item5_sum = 0;
    int item6_sum = 0;
    
    unsigned int t, travdirtime;  
    
    map<string, string> myAddrPair;
    map<int, int> myBytePair;

    pthread_mutex_lock(&result.mutex);    
    myAddrPair = result.m;
    pthread_mutex_unlock(&result.mutex);
       
    string fname;

    fname = std::to_string(targ->id);

    std::cout << "FUNC0:thread ID: " << fname << " - reading." << std::endl; 

    ifstream ifs(fname);

    start_timer(&t);   

    string str;
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;

      while(getline(stream,token,',')){

	if(counter==0)
	  {
	    src = token;
	  }
	if(counter==1)
	  {
	    dst = token;
	  }
	if(counter==2)
	  {
	    item1 =  std::atoi(token.c_str());
	  }
      	if(counter==3)
	  {
	    item2 =  std::atoi(token.c_str());
	  }
	if(counter==4)
	  {
	    item3 =  std::atoi(token.c_str());
	  }
	if(counter==5)
	  {
	    item4 =  std::atoi(token.c_str());
	  }	
	if(counter==6)
	  {
	    item5 =  std::atoi(token.c_str());
	  }
	if(counter==7)
	  {
	    item6 =  std::atoi(token.c_str());
	  }
	
        counter = counter + 1;
      }
      
      map<string, string>::iterator itr;

      map_counter = 0;  
      for (itr = myAddrPair.begin(); itr != myAddrPair.end(); itr++)
	{
	  if(src == itr->first && dst == itr->second) {
	    
	    pthread_mutex_lock(&result2.mutex);

	    std::map<int, int>::iterator it;

	    /* item1 */
	    it = result2.item1.find(map_counter);
	    if(it == result2.item1.end())
	      {
		result2.item1.insert(std::make_pair(map_counter, item1));
	      }
	    else
	      {
	        item1_sum = 0;
		item1_sum = (int)it->second + item1_sum;
		result2.item1.erase(map_counter);
		result2.item1.insert(std::make_pair(map_counter, item1_sum));
	      }

	    /* item2 */
	    it = result2.item1.find(map_counter);
	    if(it == result2.item2.end())
	      {
		result2.item2.insert(std::make_pair(map_counter, item2));
	      }
	    else
	      {
	        item2_sum = 0;
		item2_sum = (int)it->second + item2_sum;
		result2.item2.erase(map_counter);
		result2.item2.insert(std::make_pair(map_counter, item2_sum));
	      }

	    /* item3 */
	    it = result2.item3.find(map_counter);
	    if(it == result2.item3.end())
	      {
		result2.item3.insert(std::make_pair(map_counter, item3));
	      }
	    else
	      {
	        item3_sum = 0;
		item3_sum = (int)it->second + item3_sum;
		result2.item3.erase(map_counter);
		result2.item3.insert(std::make_pair(map_counter, item3_sum));
	      }

	    /* item4 */
	    it = result2.item4.find(map_counter);
	    if(it == result2.item4.end())
	      {
		result2.item4.insert(std::make_pair(map_counter, item4));
	      }
	    else
	      {
	        item4_sum = 0;
		item4_sum = (int)it->second + item4_sum;
		result2.item4.erase(map_counter);
		result2.item4.insert(std::make_pair(map_counter, item4_sum));
	      }

	    /* item5 */
	    it = result2.item5.find(map_counter);
	    if(it == result2.item5.end())
	      {
		result2.item5.insert(std::make_pair(map_counter, item5));
	      }
	    else
	      {
	        item5_sum = 0;
		item5_sum = (int)it->second + item5_sum;
		result2.item5.erase(map_counter);
		result2.item5.insert(std::make_pair(map_counter, item5_sum));
	      }

	    /* item6 */
	    it = result2.item1.find(map_counter);
	    if(it == result2.item6.end())
	      {
		result2.item6.insert(std::make_pair(map_counter, item6));
	      }
	    else
	      {
	        item6_sum = 0;
		item6_sum = (int)it->second + item6_sum;
		result2.item6.erase(map_counter);
		result2.item6.insert(std::make_pair(map_counter, item6_sum));
	      }

	    pthread_mutex_unlock(&result2.mutex);
	    
	  } // if(src == itr->first && dst == itr->second) {

	  map_counter++;	  
      }

      /*
      if(counter2 % N_PERCENT_LINES ==0)
	{
	  std::cout << "thread:" << targ->id << ": " << counter2/N_PERCENT_LINES << "% - done." << std::endl;

	  travdirtime = stop_timer(&t);
	  print_timer(travdirtime);      

	  start_timer(&t);   
	}
      */

      counter2 = counter2 + 1;
      
    } // while(getline(ifs,str)){

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

    std::cout << "reduce" << std::endl;
   
    std::vector<int> item1;
    std::vector<int> item2;
    std::vector<int> item3;
    std::vector<int> item4;
    std::vector<int> item5;
    std::vector<int> item6;

    map<int, int>::iterator itr2;
    counter = 0;
    for (itr2 = result2.item1.begin(); itr2 != result2.item1.end(); itr2++)
      {	
	item1.push_back(itr2->second);
	counter = counter + 1;
      }

    counter = 0;
    for (itr2 = result2.item2.begin(); itr2 != result2.item2.end(); itr2++)
      {	
	item2.push_back(itr2->second);
	counter = counter + 1;
      }

    counter = 0;
    for (itr2 = result2.item3.begin(); itr2 != result2.item3.end(); itr2++)
      {	
	item3.push_back(itr2->second);
	counter = counter + 1;
      }

    counter = 0;
    for (itr2 = result2.item4.begin(); itr2 != result2.item4.end(); itr2++)
      {	
	item4.push_back(itr2->second);
	counter = counter + 1;
      }

    counter = 0;
    for (itr2 = result2.item5.begin(); itr2 != result2.item5.end(); itr2++)
      {	
	item5.push_back(itr2->second);
	counter = counter + 1;
      }

    counter = 0;
    for (itr2 = result2.item6.begin(); itr2 != result2.item6.end(); itr2++)
      {	
	item6.push_back(itr2->second);
	counter = counter + 1;
      }

    map<string, string>::iterator itr;
    counter = 0;
    for (itr = result.m.begin(); itr != result.m.end(); itr++)
      {
	std::cout << itr->first << "," << itr->second << "," << item1[counter] << "," << item2[counter] << "," << item3[counter]<< "," << item4[counter]<< "," << item5[counter] << "," << item6[counter] << std::endl;

	outputfile::cout << itr->first << "," << itr->second << "," << item1[counter] << "," << item2[counter] << "," << item3[counter]<< "," << item4[counter]<< "," << item5[counter] << "," << item6[counter] << std::endl;
	
	counter = counter + 1;
      }

    outputfile.close();
}
