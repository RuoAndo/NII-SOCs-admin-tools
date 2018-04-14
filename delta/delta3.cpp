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

#define THREAD_NUM 480

#define DISPLAY_RATIO 100

using namespace Eigen;
using namespace std;

typedef struct _thread_arg {
    int id;
} thread_arg_t;

/* srcIP, destIP */
typedef struct _result {
  vector<string> v;
  pthread_mutex_t mutex;
} result_t;
result_t result;

/* dataNo(counter), bytes */
typedef struct _result2 {
  map<int, vector<string> > previous;
  // map<int, int> diff;
  pthread_mutex_t mutex;
} result2_t;
result2_t result2;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;

    int counter = 0;
    int counter2 = 0;
    
    string src;
    string dst;

    unsigned int t, travdirtime;  
    
    std::cout << "FUNC0:thread ID: " << targ->id << " - start." << std::endl; 

    string fname;

    // fname = "x0" + std::to_string(targ->id);

    if(targ->id < 10)
      {
	fname = "x0000" + std::to_string(targ->id);
      }
    else if(targ->id < 100)
      {
	fname = "x000" + std::to_string(targ->id);
      }
    else if(targ->id < 1000)
      {
	fname = "x00" + std::to_string(targ->id);
      }
    else
      {
	fname = "x0" + std::to_string(targ->id);
      }
    
    std::cout << "FUNC0:thread ID: " << fname << " - reading." << std::endl; 

    ifstream ifs(fname);
    
    string str;
    while(getline(ifs,str)){

      string token;
      istringstream stream(str);
      counter = 0;
      while(getline(stream,token,',')){

	if(counter==1)
	  src = token;

	// std::cout << src << std::endl;
	
	counter = counter + 1;
      }

      pthread_mutex_lock(&result.mutex);
      result.v.push_back(src);
      pthread_mutex_unlock(&result.mutex);
          
    } // while(getline(ifs,str)){

    std::cout << "FUNC:thread ID: " << targ->id << " - done." << std::endl;
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
    
    string srcIP;
    string myValue;
    
    unsigned int t, travdirtime;         
    string fname;

    // fname = "x0" + std::to_string(targ->id);

    if(targ->id < 10)
      {
	fname = "x0000" + std::to_string(targ->id);
      }
    else if(targ->id < 100)
      {
	fname = "x000" + std::to_string(targ->id);
      }
    else if(targ->id < 1000)
      {
	fname = "x00" + std::to_string(targ->id);
      }
    else
      {
	fname = "x0" + std::to_string(targ->id);
      }

    vector<string> myV;
    vector<string> myV2;
    
    pthread_mutex_lock(&result.mutex);    
    myV = result.v;
    pthread_mutex_unlock(&result.mutex);

    /*
    pthread_mutex_lock(&result2.mutex);    
    myV2 = result2.previous.;
    pthread_mutex_unlock(&result2.mutex);
    */    

    std::cout << "FUNC1:thread ID: " << fname << " - reading." << std::endl; 

    ifstream ifs(fname);

    start_timer(&t);   

    string str;
    
    while(getline(ifs,str)){
      string token;
      istringstream stream(str);
      counter = 0;

      while(getline(stream,token,',')){
	srcIP = token;	

	if(counter==0)
	  {
	    myValue = token;
	  }
	
	if(counter==1)
	  {
	    srcIP = token;
	  }
       
	// std::cout << srcIP << std::endl;

        counter = counter + 1;
      }
      
      vector<string>::iterator cIter = find( myV.begin(), myV.end() , srcIP );

      if( cIter != myV.end() ){
	
	size_t index = std::distance(myV.begin(), cIter);

	/*
	std::cout << "FOUND at index:" << index << ":" << myV[index] << std::endl;
	*/

	pthread_mutex_lock(&result2.mutex);    
	result2.previous[index].push_back(myValue);
	pthread_mutex_unlock(&result2.mutex);
	
      }
      
      else {
	// std::cout << "not FOUND" << std::endl;
      }
      
    } // while(getline(ifs,str)){

    std::cout << "FUNC1:thread ID: " << targ->id << " - done." << std::endl; 
    
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int counter = 0;
    
    int PROC_NO = 0;

    vector<string> myV;
    vector<int> myDiff;
    
    int i;

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    std::sort(result.v.begin(), result.v.end());
    result.v.erase(std::unique(result.v.begin(), result.v.end()), result.v.end());
    
    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        pthread_create(&handle[i], NULL, (void*)thread_func1, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    
    // std::cout << "map size() is " << result.m.size() << std::endl; 

    /*
      std::for_each(result.v.begin(), result.v.end(), [](const std::string& x) {
	std::cout << x << std::endl;
      });
    */

    map<int, vector<string> >::iterator itr2;

    string out_fname_delta = "delta";
    ofstream outputfile_delta(out_fname_delta);
    
    counter = 0;    
    for (itr2 = result2.previous.begin(); itr2 != result2.previous.end(); itr2++)
      {
	myV = result2.previous[counter];

	string out_fname = "s" + std::to_string(counter);
	ofstream outputfile(out_fname);

	if(counter % DISPLAY_RATIO == 0)
	  {
	    std::cout << "now wrting file " << counter << "..." << std::endl;
	  }
	outputfile << counter << ":" << result.v[counter] << ":";

	std::sort(myV.begin(), myV.end() );
	
	string constr;

	for(i = 0; i < myV.size(); i++)
	  {
	    outputfile << myV[i] << ","; // << std::endl;
	  }

	outputfile << std::endl;
	outputfile.close();

	/* diff */

	string out_fname2 = "d" + std::to_string(counter);
	ofstream outputfile2(out_fname2);

	if(counter % DISPLAY_RATIO == 0)
	  {
	    std::cout << "now wrting file " << counter << "..." << std::endl;
	  }
	
	outputfile2 << counter << ":" << result.v[counter] << ":";

	std::sort(myV.begin(), myV.end() );

	long diff;

	for(i = 1; i < myDiff.size(); i++)
	  myDiff.pop_back();

	for(i = 1; i < myV.size(); i++)
	  {
	    diff = std::stol(myV[i]) - std::stol(myV[i-1]);
	    myDiff.push_back(diff);
	    outputfile2 << diff << ","; // << std::endl;
	  }

	outputfile2 << std::endl;
	outputfile2.close();

	vector<int> myDiff_org = myDiff;

	std::sort(myDiff.begin(), myDiff.end());
	myDiff.erase(std::unique(myDiff.begin(), myDiff.end()), myDiff.end());
	
	for(i = 1; i < myDiff.size(); i++)
	  {
	    size_t n_count = std::count(myDiff_org.begin(), myDiff_org.end(), myDiff[i]);

	    if(n_count > 1)
	      {
		//std::cout << myDiff[i] << "," << n_count << std::endl;
		if(counter % DISPLAY_RATIO == 0)
		  {
		    std::cout << "DELTA," << counter << "," << result.v[counter] << "," << myDiff[i] << "," << n_count << std::endl;
		  }
		outputfile_delta << "DELTA," << counter << "," << result.v[counter] << "," << myDiff[i] << "," << n_count << std::endl;
	      }
	  }

	counter = counter + 1;
	
      }

	outputfile_delta.close();
    
    std::cout << "map size (IPs) is:" << result.v.size() << std::endl;
    
}
	  
