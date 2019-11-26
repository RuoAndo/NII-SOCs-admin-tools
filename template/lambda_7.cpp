#include<boost/spirit/include/qi.hpp>
#include<string>
#include<iostream>
#include "csv.hpp"

namespace qi = boost::spirit::qi;
using namespace std;

std::string timestamp_string;

int main(int argc, char** argv) {
  using qi::int_;
  using qi::parse;
  using qi::char_;
  {
    
    /*
    std::string str("{46}");
    std::string::iterator first = str.begin(), last = str.end();
    
    auto w = [](int x){std::cout << x << std::endl;};
    */

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
	cout << timestamp << endl;

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

	  // std::cout << timestamp_string << std::endl;
	  std::cout << "lamba applied:" << x << std::endl;
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

	cout << timestamp_string << endl;
    }
  }    
  return 0; 
}

