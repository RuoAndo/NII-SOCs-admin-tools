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
    
int main( int argc, char* argv[] ) {

  char d[]="ccc";
  static MyString* Data;

  int N = atoi(argv[2]);  
  Data = new MyString[N]; 

  test(d);
  test(d);

  const string csv_file = std::string(argv[1]); 
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

      // printf("%s \n",cstr);
      test(cstr);
      
      delete[] cstr; 
    }    
  }
  catch (...) {
    cout << "EXCEPTION!" << endl;
    return 1;
  }

  char bbb[128];
  
  for( StringTable::iterator i=table.begin(); i!=table.end(); ++i )
    {
        // sprintf(bbb,"%c", i->first);
	// printf("%s \n", bbb);
        cout << i->first << "," << i->second << endl;
        // printf("%c,%d\n",i->first, i->second);
    }
}
