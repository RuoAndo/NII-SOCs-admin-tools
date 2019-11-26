#include<boost/spirit/include/qi.hpp>
#include<string>
#include<iostream>
#include "csv.hpp"

#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"  

using namespace tbb;

struct HashCompare {
  static size_t hash( unsigned long long x ) {
    return (size_t)x;
  }
  static bool equal( unsigned long long x, unsigned long long y ) {
    return x==y;
  }
};

typedef concurrent_hash_map<unsigned long long, int, HashCompare> TimeStamp_msec;
static TimeStamp_msec timestamp_msec;    

namespace qi = boost::spirit::qi;
using namespace std;

std::string timestamp_string;

int main(int argc, char** argv) {
  using qi::int_;
  using qi::parse;
  using qi::char_;
  {
    int counter = 0;
  
    int N = atoi(argv[2]);  
    double result;
    
    const string sfile = std::string(argv[1]); 
    vector<vector<string>> sdata; 
	  
    try {
      Csv objCsv(sfile);
      if (!objCsv.getCsv(sdata)) {
	cout << "read ERROR" << endl;
	return 1;
      }
    }
    catch (...) {
      cout << "EXCEPTION (READ)" << endl;
      return 1;
    }

    
    for (unsigned int row = 0; row < sdata.size(); row++) {
        vector<string> rec = sdata[row];
	     
	std::string timestamp = rec[0];
	// cout << timestamp << endl;

	std::string::iterator first = timestamp.begin(), last = timestamp.end();
	
	auto w = [](int x){
	  
	  ostringstream ss;
	  ss << x;

	  if(ss.str().length() == 1)
	    {
	      // std::cout << "HIT" << std::endl;
	      timestamp_string = timestamp_string + "0" + ss.str();
	    }
	  else
	    {
	      timestamp_string = timestamp_string + ss.str();
	    }

	  // std::cout << "lamba applied to:" << x << std::endl;
	};

	timestamp_string = "";    
	parse(
	      first,
	      last,
	      '"' >>
	      int_[w] >>
	      '/' >>
	      int_[w] >>
	      '/' >>
	      int_[w] >>
	      ' ' >> 
	      int_[w] >>
	      ':' >>
	      int_[w] >>
	      ':' >>
	      int_[w]	      
	      );

	// cout << timestamp_string << endl;
	//unsigned long long timestamp_ull = 1;
	
	unsigned long long timestamp_ull = stoull(timestamp_string);
	TimeStamp_msec::accessor a;
	timestamp_msec.insert(a, timestamp_ull);
	a->second += 1;           
	
    }

    cout << " " << endl;

    for( TimeStamp_msec::iterator i=timestamp_msec.begin(); i!=timestamp_msec.end(); ++i )
      {
	/*
	if(counter>5)
	  break;
	*/	

	cout << i->first << "," << i->second << endl;
	counter++;
      }                         

    
  }

  
  return 0; 
}

