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
// long N = 50000000;
const int size_factor = 2;

std::vector<string> all_pair;
std::vector<int> all_count;
std::vector<string> v;
std::vector<string> v2;

typedef concurrent_hash_map<MyString,int> StringTable;
typedef concurrent_hash_map<MyString, vector<string> > StringTable2;

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
    StringTable2& table;
    Tally2( StringTable2& table_ ) : table(table_) {}
    void operator()( const blocked_range<MyString*> range ) const {
      int counter = 0;
        for( MyString* p=range.begin(); p!=range.end(); ++p ) {
            StringTable2::accessor a;
            table.insert( a, *p );
            a->second.push_back(v[counter].c_str());
	    counter = counter + 1;
        }
    }
};

static MyString* Data;

static void CountOccurrences(int nthreads, int N) {

    int max_count;
  
    StringTable table;    
    tick_count t0 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, 1000 ), Tally(table) );
    tick_count t1 = tick_count::now();

    StringTable2 table2;    
    tick_count t2 = tick_count::now();
    parallel_for( blocked_range<MyString*>( Data, Data+N, 1000 ), Tally2(table2) );
    tick_count t3 = tick_count::now();

    // ofstream outputfile("tmp");  
    unsigned long n = 0;
    for( StringTable::iterator i=table.begin(); i!=table.end(); ++i ) {
        if( verbose && nthreads )
            printf("%s,%d\n",i->first.c_str(),i->second);

	// all_count.push_back(i->second);
	all_pair.push_back(i->first.c_str());
	
        n += i->second;	
    }
    printf("1 total = %10lu  unique = %u  time = %g\n", n, unsigned(table.size()), (t1-t0).seconds());

    max_count = n;
    
    n = 0;
    ofstream outputfile("tmp");  
    for( StringTable2::iterator i=table2.begin(); i!=table2.end(); ++i ) {
        if( verbose && nthreads )
            printf("%s,",i->first.c_str());

	// printf("%s,%d,",i->first.c_str(),i->second.size());
        outputfile << i->first.c_str() << "," << i->second.size() << ",";
	
	vector<string>::iterator it = i->second.begin();

	while( it != i->second.end() ) {
	  outputfile << *it << " " ;
	  ++it;
	}

	outputfile << "\n";
        // printf("\n");

	n += i->second.size();
    }
    printf("2 total = %10lu  unique = %u  time = %g\n", n, unsigned(table2.size()), (t1-t0).seconds());
    outputfile.close();
    
    /*
    int i;
    ofstream outputfile("tmp");  
    for(i=0; i< max_count ; i++)
      {
	outputfile << all_pair[i] << "," << all_count[i] << std::endl;
      }
    outputfile.close();
    */
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

	// String fname = argv[0].c_str();	
	// const string csv_file = "all-50000000";
	
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

	    std::string pair = rec[1] + "," + rec[2] + "," + rec[3] + "," + rec[4];
	    
	    char* cstr = new char[pair.size() + 1]; 
	    std::strcpy(cstr, pair.c_str());        

	    /* application */
	    Data[row] += cstr;
	    v.push_back(rec[8].c_str()); 
	    
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
	      /*
                if ( !silent ) printf("serial run   ");
                task_scheduler_init init_serial(1);
                CountOccurrences(1);
	      */
            }
            { // parallel run (number of threads is selected automatically)
                if ( !silent ) printf("parallel run \n");
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
