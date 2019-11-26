#include<string>
#include<iostream>
#include "csv.hpp"

#include <boost/spirit/include/qi.hpp>
#include <boost/fusion/include/struct.hpp>
#include <boost/bind.hpp>
#include <boost/range/algorithm/for_each.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lambda/bind.hpp>

using namespace std;
namespace bll = boost::lambda;
namespace qi = boost::spirit::qi;
// using qi::int_;
// using qi::parse;
// using qi::char_;

double Average(const boost::fusion::vector<double, double>& x)
{
    return (boost::fusion::at_c<0>(x) + boost::fusion::at_c<1>(x)) * 0.5;
}

int main(int argc, char** argv) {
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
	
	parse(
	      first,
	      last,
	      '"' >>
	      qi::int_ >>
	      '/' >>
	      qi::int_ >>
	      '/' >>
	      qi::int_
	      );	
    }

    return 0; 
}

