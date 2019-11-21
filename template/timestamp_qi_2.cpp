#include <string>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>

#include <boost/spirit/include/qi.hpp>
#include <boost/spirit/include/phoenix.hpp>

#include "utility.h"

#include "csv.hpp"


// #include <boost/spirit.hpp>

// using namespace boost::spirit;
using namespace std;

int main( int argc, char* argv[] ) {

  int counter = 0;
  
  int N = atoi(argv[2]);  
  double result;

  using namespace boost::spirit;
  
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

    std::string timestamp = rec[37];
    cout << timestamp << endl;

    rule<> r = str_p("ISBN") >>
      (str_p("978") | str_p("979")) >>
      ch_p('-') >>
      uint_p >>
      ch_p('-') >>
      uint_p >>
      ch_p('-') >>
      uint_p >>
      ch_p('-') >>
      (digit_p | ch_p('X')) >>
      end_p;

    /*
    std::cout <<  
      parse(timestamp,
	    str_p("ISBN") >>
	    (str_p("978") | str_p("979")) >>
	    ch_p('-') >>
	    uint_p >>
	    ch_p('-') >>
	    uint_p >>
	    ch_p('-') >>
	    uint_p >>
	    ch_p('-') >>
	    (digit_p | ch_p('X')) >>
	    end_p
	    ).full
        << std::endl;
    */
  }
    
  return 0;
}
