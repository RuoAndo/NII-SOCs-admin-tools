#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>

// #include <boost/spirit/include/qi.hpp>
// #include <boost/spirit/include/phoenix.hpp>
#include <boost/spirit/include/classic.hpp>

#include "utility.h"
#include "csv.hpp"

// #include <boost/spirit.hpp>

using namespace boost::spirit;
using namespace std;

int main( int argc, char* argv[] ) {

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

  // "2019/11/17 03:07:51"
  // ./a.out "ISBN979-12-24234-34234-X"
  
  for (unsigned int row = 0; row < sdata.size(); row++) {
    vector<string> rec = sdata[row];

    std::string timestamp = rec[0];
    cout << timestamp << endl;
        
    std::cout <<  
            qi::parse(timestamp,
	    str_p("2019") >>
	    ch_p('/') >>
	    uint_p >>
	    ch_p('/') >>
	    uint_p >>
	    ch_p(' ') >>
	    uint_p >>
	    ch_p(':') >>
	    uint_p >>
	    ch_p(':') >>
	    uint_p >>
	    end_p
	    ).full
        << std::endl;
  }
    
  return 0;
}
