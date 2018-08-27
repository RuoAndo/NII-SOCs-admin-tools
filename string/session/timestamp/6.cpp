#if __linux__ && defined(__INTEL_COMPILER)
#define __sync_fetch_and_add(ptr,addend) _InterlockedExchangeAdd(const_cast<void*>(reinterpret_cast<volatile void*>(ptr)), addend)
#endif
#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>

#include <stdio.h>
#include <pthread.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"
typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

using namespace tbb;
using namespace std;

#define THREAD_NUM 2

typedef struct _thread_arg {
    int thread_no;
    int lineNumber;
} thread_arg_t;


struct HashCompare {
  static size_t hash( const char& x ) {
    return (size_t)x;
  }
  static bool equal( const char& x, const char& y ) {
    return x==y;
  }
};

struct HashCompare2 {
  static size_t hash( const char& x ) {
    return (size_t)x;
  }
  static bool equal( const char& x, const char& y ) {
    return x==y;
  }
};

typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString; 
// typedef concurrent_hash_map<char, int, HashCompare> StringTable;
// typedef concurrent_hash_map<string, int, HashCompare2> StringTable;
// typedef concurrent_hash_map<string, int, HashCompare> StringTable;  
typedef concurrent_hash_map<string,int> StringTable;

StringTable table;

static void test(const char *c)
{
    StringTable::accessor a;

    std::string tmp = std::string(c);
    table.insert(a, tmp);
    a->second += 1;
}

void thread_func(void *arg) {

  thread_arg_t* targ = (thread_arg_t *)arg;
  int i;

  printf("thread%d \n", targ->thread_no);
  
    /*
    for (i = 0; i < DATA_NUM; i++) 
        printf("thread%d : %d + 1 = %d\n",
            targ->thread_no, targ->data[i], targ->data[i] + 1);
    */

  static MyString* Data;
  int N = targ->lineNumber;  
  Data = new MyString[N]; 

  const string csv_file = std::to_string(targ->thread_no); 
  vector<vector<string>> data; 
  
  try {
    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
      cout << "read ERROR" << endl;
      return 1;
    }

    for (unsigned int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 
      std::string pair = rec[1] + "," + rec[2]; 
      const char* cstr = new char[pair.size() + 1]; 
      std::strcpy(cstr, pair.c_str());        
      Data[row] += cstr;
      // test(cstr);

      StringTable::accessor a;

      std::string tmp = std::string(cstr);
      table.insert(a, tmp);
      a->second += 1;
      
      delete[] cstr; 
    }    
  }
  catch (...) {
    cout << "EXCEPTION!" << endl;
    return 1;
  }
    
}

int main( int argc, char* argv[] ) {

    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i;

    int N = atoi(argv[1]);  

    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].thread_no = i;
	targ[i].lineNumber = N;
	pthread_create(&handle[i], NULL, (void *)thread_func, (void *)&targ[i]);
    }
    

    for (i = 0; i < THREAD_NUM; i++)
        pthread_join(handle[i], NULL);
    
  for( StringTable::iterator i=table.begin(); i!=table.end(); ++i )
    {
        cout << i->first << "," << i->second << endl;
    }
}
