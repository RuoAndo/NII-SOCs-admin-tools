#include <iostream>
#include <boost/spirit/include/qi.hpp>
#include <boost/fusion/include/vector.hpp>

int main()
{
   namespace qi = boost::spirit::qi;
   typedef boost::fusion::vector<std::string, std::string> value_type;
   typedef qi::rule<std::string::const_iterator, value_type()> rule_type;

   const rule_type r = *(qi::char_ - '(') >> '(' >> *(qi::char_ - ')') >> ')';

   const std::string s = "abc(123)";
   value_type result;
   if (!qi::parse(s.begin(), s.end(), r, result))
   {
       std::cout << "failed" << std::endl;
       return 1;
   }

   std::cout << boost::fusion::at_c<0>(result) << std::endl
             << boost::fusion::at_c<1>(result) << std::endl;
}

