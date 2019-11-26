#include <iostream>
#include <string>
#include "csv.hpp"


#include <boost/fusion/sequence/intrinsic/at_c.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lambda/bind.hpp>
#include <boost/spirit/include/qi.hpp>
#include <boost/fusion/include/struct.hpp>
#include <boost/range/algorithm/for_each.hpp>

using namespace std;
using namespace boost::spirit::qi;
namespace bll = boost::lambda;

double Average(const boost::fusion::vector<double, double>& x)
{
    return (boost::fusion::at_c<0>(x) + boost::fusion::at_c<1>(x)) * 0.5;
}

int ok(int x)
{
  cout << "boost_lambda_ok:" << x << endl;
  return 1;
}

int main(int argc, char** argv) 
{
      int counter = 0;
  
      int N = atoi(argv[2]);  
      double result;
    
      const std::string sfile = std::string(argv[1]); 
      vector<vector<std::string>> sdata; 
	  
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
      vector<std::string> rec = sdata[row];
	     
      std::string timestamp = rec[0];
      cout << timestamp << endl;

      std::string::iterator first = timestamp.begin(), last = timestamp.end();

      int val;
      
      parse(
	    first,
	    last,
	    '"' >>
	    int_ >>
	    '/' >>
	    int_ >>
	    '/' >>
	    int_ >>
	    ' ' >> 
	    int_ >>
	    ':' >>
	    int_ >>
	    ':' >>
	    int_[ok]
	    );
    }

    /*
      std::string s = "1,2";
      auto first = s.begin();
      double val;
      bool success = parse(
      first,
      s.end(),
      (double_ >> ',' >> double_)[bll::var(val) = bll::bind(Average, bll::_1)]
      );
      if (success)
      {
      std::cout << val << std::endl;
      }
    */
}
