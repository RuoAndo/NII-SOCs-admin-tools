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
#include <bitset>

#include <map>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
//  #include "tbb/tbb_allocator.hz"
#include "utility.h"

#include "csv.hpp"
typedef std::basic_string<char,std::char_traits<char>,tbb::tbb_allocator<char> > MyString;

/*
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/generate.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
*/

#include <algorithm>
#include <cstdlib>
// #include "util.h"

#include "tbb/parallel_sort.h"
#include <math.h>

using namespace tbb;
using namespace std;

static bool verbose = false;
static bool silent = false;

struct HashCompare {
  static size_t hash( unsigned long long x ) {
    return (size_t)x;
  }
  static bool equal( unsigned long long x, unsigned long long y ) {
    return x==y;
  }
};

typedef concurrent_hash_map<unsigned long long, int, HashCompare> CharTable;
static CharTable table;   

int main( int argc, char* argv[] ) {

  const int N = atoi(argv[2]);  
  char* tmpchar;

  struct in_addr inaddr;
  char *some_addr;

  // unsigned long long timestamp;
  int counter = 0;

  std::cout << "reading...." << endl;
  tbb::tick_count mainStartTime = tbb::tick_count::now();

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data)) {
     cout << "read ERROR" << endl;
     return 1;
     }

  vector<unsigned long long> timestamp;
  vector<int> counted;
  
  for (int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row];
      // std::cout << stoull(rec[0]) << endl;
      // timestamp[row]= stoll(rec[0]);
      // std::cout << stoull(rec[0]) << endl;
      timestamp.push_back(stoull(rec[0].substr(0,14)));
      counted.push_back(1);
  }
  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
  
  /*
  std::cout << "sorting..." << endl;
  mainStartTime = tbb::tick_count::now();
  tbb::parallel_sort(timestamp.begin(),timestamp.end(),std::greater<unsigned long long>());
  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());    
  */

  std::cout << "reducing..." << endl;
  mainStartTime = tbb::tick_count::now();
  for (int row = 0; row < data.size(); row++) {
      CharTable::accessor a;
      // string timestamp_string to_string(timestamp
      table.insert(a, timestamp[row]);
      a->second += counted[row];   
  }

  std::map<unsigned long long,int> reduced;
  
  for( CharTable::iterator i=table.begin(); i!=table.end(); ++i )
    {
      reduced[i->first] = i->second;
    }
  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());    

  mainStartTime = tbb::tick_count::now();
  std::cout << "writing..." << endl;
  std::remove("tmp-tbb");
  ofstream outputfile("tmp-tbb");

  for( auto i = reduced.begin(); i != reduced.end() ; ++i ) {
      // outputfile << i->first << "," << i->second << "\n";

    string tmpstring = std::to_string(i->first);
      outputfile << tmpstring.substr( 0, 4 )
      << "-"
      << tmpstring.substr( 4, 2 )
      << "-"
      << tmpstring.substr( 6, 2 )
      << " "
      << tmpstring.substr( 8, 2 )
      << ":"
      << tmpstring.substr( 10, 2 )
      << ":"
      << tmpstring.substr( 12, 2 )
      << "," << i->second << endl;
       
  }  
  outputfile.close();
  utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());    
  
  return 0;

}
