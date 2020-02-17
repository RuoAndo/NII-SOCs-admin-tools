#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>
#include <string>

#include <boost/spirit/include/qi.hpp>
#include <boost/fusion/include/std_pair.hpp>
#include <boost/any.hpp>
#include <boost/tokenizer.hpp>

namespace qi = boost::spirit::qi;
namespace ascii = boost::spirit::ascii;

using namespace std;

template <class... Args>
std::string format(const char* fmt, Args&&... args)
{
  std::streambuf* backup = std::cout.rdbuf();
  std::stringstream sout;
  std::streambuf* soutbuf = sout.rdbuf();
  std::cout.rdbuf(soutbuf);

  std::fprintf(stdout, fmt, args...);

  std::string result = sout.str();

  std::cout.rdbuf(backup);
  return result;
}

std::string replaceOtherStr(std::string &replacedStr, std::string from, std::string to) {
  const unsigned int pos = replacedStr.find(from);
  const int len = from.length();

  if (pos == std::string::npos || from.empty()) {
    return replacedStr;
  }

  return replacedStr.replace(pos, len, to);
}

std::string replaceAll(std::string &replacedStr, std::string from, std::string to) {
  unsigned int pos = replacedStr.find(from);
  int toLen = to.length();

  if (from.empty()) {
    return replacedStr;
  }

  while ((pos = replacedStr.find(from, pos)) != std::string::npos) {
    replacedStr.replace(pos, from.length(), to);
    pos = toLen + 2;
  }
  return replacedStr;
}

template<typename Iterator>
struct json_grammar : qi::grammar<Iterator, boost::any(), ascii::space_type>
{
  json_grammar()
    : json_grammar::base_type(element)
  {
    number %= qi::double_;
    date %= qi::lexeme['"' >> (qi::long_ - '/') >> (qi::long_ - '/') >> (qi::long_ - '/') >>
		       (qi::long_ - ':') >> (qi::long_ - ':') >> (qi::long_) >> '"'];

    array %= qi::eps >> '[' >> element % ',' >> ']';
    array2 %= qi::eps >> '[' >> element >> ']';
    
    string %= qi::lexeme['"' >> *(ascii::char_ - '"' | '/' | '-' )>> '"'];
    key_value %= string >> ':' >> element;
    object %= qi::eps >> '{' >> key_value % ',' >> '}';
    element %= array | object | string | number | array2 | date;
  }

  qi::rule<Iterator, std::vector<boost::any>(), ascii::space_type> array;
  qi::rule<Iterator, std::vector<boost::any>(), ascii::space_type> array2;
  qi::rule<Iterator, std::pair<std::string, boost::any>(), ascii::space_type> key_value;
  qi::rule<Iterator, std::map<std::string, boost::any>(), ascii::space_type> object;
  qi::rule<Iterator, std::string(), ascii::space_type> string;
  qi::rule<Iterator, double(), ascii::space_type> number;

  qi::rule<Iterator, boost::any(), ascii::space_type> date;
  qi::rule<Iterator, boost::any(), ascii::space_type> element;
};

int main(int argc, char **argv) {
  typedef json_grammar<std::string::const_iterator> Parser;
  Parser p;

  ifstream ifs(argv[1], ios::in);
  if(!ifs){
    cerr << "Error: file not opened." << endl;
    return 1;
  }

  string tmp;
  while(getline(ifs, tmp)){
    cout << tmp << endl; 

    const std::string str = tmp;
    
    boost::any result;
    if(qi::phrase_parse(str.begin(), str.end(), p, ascii::space, result))
      {
	std::cout << "format ok" << std::endl;
	std::map<std::string, boost::any> p = boost::any_cast<std::map<std::string, boost::any>>(result);
	std::cout << boost::any_cast<std::string>(p["capture_time"]) << std::endl;	std::cout << boost::any_cast<std::string>(p["source_ip"]) << std::endl;
      }
  }

  ifs.close();

  return 0;
}
