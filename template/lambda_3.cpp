#include<boost/spirit/include/qi.hpp>
#include<string>
#include<iostream>

namespace qi = boost::spirit::qi;

int main(){
  using qi::int_;
  using qi::parse;
  {
    std::string str("{46}");
    std::string::iterator first = str.begin(), last = str.end();
    
    auto w = [](int x){std::cout << x << std::endl;};
    
    parse(
      first,
      last,
      '{' >> int_[w] >> '}'
    );
 
  }
  return 0; 
}

