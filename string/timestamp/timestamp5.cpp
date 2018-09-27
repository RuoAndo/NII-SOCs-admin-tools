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

static bool verbose = false;
static bool silent = false;

const int size_factor = 2;

// typedef concurrent_hash_map<MyString,int> StringTable;
typedef concurrent_hash_map<MyString,std::vector<string>> StringTable;
std::vector<string> v_timestamp;

struct Tally {
    StringTable& table;
    Tally( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
      for( MyString* p=range.begin(); p!=range.end(); ++p ) {
	StringTable::accessor a;
	table.insert( a, *p );
	// a->second += 1;
	a->second.push_back(v_timestamp[counter]);
	counter = counter + 1;
        }
    }
};

static MyString* Data;

static void CountOccurrences(int nthreads, int N) {
    StringTable table;
    
    int counter2 = 0;
    long previous_value = 0;
    long tmp_value = 0;

    
    tick_count t0 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, N ), Tally(table) );
    tick_count t1 = tick_count::now();

    ofstream outputfile("tmp-timestamp-3");  
    
    int n = 0;
    int counter = 0;
    long diff;

    std::vector<long> diff_vector;
    
    for( StringTable::iterator i=table.begin(); i!=table.end(); ++i ) {

      /*
      for(size_t c = string(*i).find_first_of("/"); c != string::npos; c = c = i->second[0].find_first_of("/")){
	i->second[0].erase(c,1);
      }

      for(size_t c = i->second[0].find_first_of(" "); c != string::npos; c = c = i->second[0].find_first_of(" ")){
	i->second[0].erase(c,1);
      }

      for(size_t c = i->second[0].find_first_of("."); c != string::npos; c = c = i->second[0].find_first_of(".")){
	i->second[0].erase(c,1);
      }

      for(size_t c = i->second[0].find_first_of(":"); c != string::npos; c = c = i->second[0].find_first_of(":")){
	i->second[0].erase(c,1);
      }

      for(size_t c = i->second[0].find_first_of("\""); c != string::npos; c = c = i->second[0].find_first_of("\"")){
	i->second[0].erase(c,1);
      }
      */

      outputfile<< i->first.c_str() << ",";
      
      counter2 = 0;
      std::vector<string>::iterator itr = i->second.begin();
      for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) {
	// outputfile << i->second[0] << ",";

	std::string tmp_string = *itr;
	
	for(size_t c = tmp_string.find_first_of(":"); c != string::npos; c = c = tmp_string.find_first_of(":")){
	  tmp_string.erase(c,1);
	}

	for(size_t c = tmp_string.find_first_of("."); c != string::npos; c = c = tmp_string.find_first_of(".")){
	  tmp_string.erase(c,1);
	}
	
	for(size_t c = tmp_string.find_first_of("/"); c != string::npos; c = c = tmp_string.find_first_of("/")){
	  tmp_string.erase(c,1);
	}

	for(size_t c = tmp_string.find_first_of("\""); c != string::npos; c = c = tmp_string.find_first_of("\"")){
	  tmp_string.erase(c,1);
	}

	for(size_t c = tmp_string.find_first_of(" "); c != string::npos; c = c = tmp_string.find_first_of(" ")){
	  tmp_string.erase(c,1);
	}

	outputfile << tmp_string << ",";
	// std::cout << tmp_string << ",";
		
	if(counter2 > 0)
	  {
	    diff = 0;
	    // std::cout << *itr << endl;
	    tmp_value = atoi(tmp_string.c_str());

	    /*
	    std::cout << "previous_value:" << previous_value << endl;
	    std::cout << "tmp_value:" << tmp_value << endl;
	    std::cout << endl;
	    */	    

	    diff = abs(tmp_value - previous_value);
	    // std::cout << "diff:" << diff << endl;
	    // std::cout << "---" << endl;
	    
	    diff = diff + 1;
	    diff_vector.push_back(diff);
	    // std::cout << previous_value << endl;
	    
	  }
	
	previous_value = atoi(tmp_string.c_str());
	
	counter2 = counter2 + 1;
      }

      // outputfile << counter2 << ",";
            
      float sum2 = 0;
      float counter3 = 0;
      float ave = 0;
      std::vector<long>::iterator itr2 = diff_vector.begin();
      
      for(auto itr2 = diff_vector.begin(); itr2 != diff_vector.end(); ++itr2) {
	tmp_value = *itr2;
        // outputfile << "TMP:" << tmp_value << ",";
	sum2 = sum2 + tmp_value;
	counter3 = counter3 + 1;
      }
      
      outputfile << counter3 << ",";
      
      if (counter3 > 0)
	ave = sum2 / (counter3 * 10000);
      else
	ave = 0;
	
      outputfile << ave;
      diff_vector.erase( diff_vector.begin(), diff_vector.end() ); 

      outputfile << endl;
      
      counter = counter + 1;
    }
    outputfile.close();
    
    printf("total = %d  unique = %u  time = %g\n", n, unsigned(table.size()), (t1-t0).seconds());
}

int main( int argc, char* argv[] ) {

  int counter = 0;
  int N = atoi(argv[2]);  

    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        if ( silent ) verbose = false;

        Data = new MyString[N];

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
	    
	    std::string pair = rec[4] + "," + rec[5] + "," + rec[7] + "," + rec[8];
	    
	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        

	    Data[row] += cstr;
	    
	    v_timestamp.push_back(rec[0].c_str());
	    
	    delete[] cstr; 
	  }
	}
	catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
	}
	
        if ( threads.first ) {
            for(int p = threads.first;  p <= threads.last; p = threads.step(p)) {
                if ( !silent ) printf("threads = %d  ", p );
                task_scheduler_init init( p );
                CountOccurrences( p, N );
            }
        } else { // Number of threads wasn't set explicitly. Run serial and parallel version
            { // serial run
	      // if ( !silent ) printf("serial run   ");
	      //  task_scheduler_init init_serial(1);
              //  CountOccurrences(1);
            }
            { // parallel run (number of threads is selected automatically)
                if ( !silent ) printf("parallel run ");
                task_scheduler_init init_parallel;
                CountOccurrences(0, N);
            }
        }

        delete[] Data;

        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
