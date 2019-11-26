#include <iostream>
#include <string>

#include <boost/fusion/sequence/intrinsic/at_c.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lambda/bind.hpp>
#include <boost/spirit/include/qi_parse.hpp>
#include <boost/spirit/include/qi_real.hpp>
#include <boost/spirit/include/qi_action.hpp>
#include <boost/spirit/include/qi_char_.hpp>
#include <boost/spirit/include/qi_sequence.hpp>

using namespace boost::spirit::qi;

namespace bll = boost::lambda;

double Average(const boost::fusion::vector<double, double>& x)
{
  return (boost::fusion::at_c<0>(x) + boost::fusion::at_c<1>(x)) * 0.5;
}

int main()
{
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
}
