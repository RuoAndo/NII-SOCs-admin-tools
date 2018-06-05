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

// ! Problem size
long N = 100000000;
// long N = 1000;
const int size_factor = 2;

std::vector<int> v;
std::vector<int> v2; 

std::vector<string> all_pair;
std::vector<int> all_count;
std::vector<int> all_bytes;


typedef concurrent_hash_map<MyString,int> StringTable;

struct Tally {
    StringTable& table;
    Tally( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable::accessor a;
            table.insert( a, *p );
            a->second += 1;
	    //a->second += v[counter];
	    counter = counter + 1;
        }
    }
};

struct Tally2 {
    StringTable& table;
    Tally2( StringTable& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable::accessor a;
            table.insert( a, *p );
            // a->second += 1;
	    a->second += v[counter];
	    counter = counter + 1;
        }
    }
};

static MyString* Data;

static void CountOccurrences(int nthreads) {
  
    StringTable table;    
    tick_count t0 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, 1000 ), Tally(table) );
    tick_count t1 = tick_count::now();

    StringTable table2;    
    tick_count t2 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, 1000 ), Tally2(table2) );
    tick_count t3 = tick_count::now();

    // ofstream outputfile("tmp");  
    int n = 0;
    for( StringTable::iterator i=table.begin(); i!=table.end(); ++i ) {
        if( verbose && nthreads )
            printf("%s,%d\n",i->first.c_str(),i->second);

	// printf("%s,%d\n",i->first.c_str(),i->second);
	// outputfile<< i->first.c_str() << "," << i->second << endl;
	all_count.push_back(i->second);

	// all_pair.push_back(i->first.c_str());
	
        n += i->second;	
    }
    // outputfile.close();
    // if ( !silent )
    printf("1 total = %d  unique = %u  time = %g\n", n, unsigned(table.size()), (t1-t0).seconds());

    // ofstream outputfile2("tmp2");  
    n = 0;
    for( StringTable::iterator i=table2.begin(); i!=table2.end(); ++i ) {
        if( verbose && nthreads )
            printf("%s,%d\n",i->first.c_str(),i->second);

	// printf("%s,%d\n",i->first.c_str(),i->second);
	// outputfile2<< i->first.c_str() << "," << i->second << endl;
	all_bytes.push_back(i->second);
	
	all_pair.push_back(i->first.c_str());
	
        n += i->second;	
    }
    // outputfile2.close();
    // if ( !silent )
    printf("2 total = %d  unique = %u  time = %g\n", n, unsigned(table2.size()), (t1-t0).seconds());

    int i;
    ofstream outputfile("tmp");  
    for(i=0; i<N; i++)
      {
	std::cout << all_pair[i] << "," << all_count[i] << "," << all_bytes[2] << std::endl;
	outputfile << all_pair[i] << "," << all_count[i] << "," << all_bytes[2] << std::endl;
      }
    outputfile.close();
}

int main( int argc, char* argv[] ) {

  int counter = 0;
  
    try {
        tbb::tick_count mainStartTime = tbb::tick_count::now();
        srand(2);

        utility::thread_number_range threads(tbb::task_scheduler_init::default_num_threads,0);

        if ( silent ) verbose = false;

        Data = new MyString[N];

	const string csv_file = "all-100000000"; 
	vector<vector<string>> data; 

	try {
	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	  }

	  for (unsigned int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 
	    // cout << rec[0];
	    // cout << endl;

	    std::string pair = rec[0] + "," + rec[1];
	    
	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        
	
	    Data[row] += cstr;

	    v.push_back(std::atoi(rec[2].c_str())); 
	    
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
                CountOccurrences( p );
            }
        } else { // Number of threads wasn't set explicitly. Run serial and parallel version
            { // serial run
	      /*
                if ( !silent ) printf("serial run   ");
                task_scheduler_init init_serial(1);
                CountOccurrences(1);
	      */
            }
            { // parallel run (number of threads is selected automatically)
                if ( !silent ) printf("parallel run \n");
                task_scheduler_init init_parallel;
                CountOccurrences(0);
            }
        }

        delete[] Data;

        utility::report_elapsed_time((tbb::tick_count::now() - mainStartTime).seconds());
       
        return 0;
	
    } catch(std::exception& e) {
        std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
    }
}
