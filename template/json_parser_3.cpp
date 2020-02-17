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
#include <boost/date_time/posix_time/posix_time.hpp>

#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"  

std::string now_str()
{
  const boost::posix_time::ptime now =
  boost::posix_time::microsec_clock::local_time();
  const boost::posix_time::time_duration td = now.time_of_day();

  const long hours        = td.hours();
  const long minutes      = td.minutes();
  const long seconds      = td.seconds();
  const long milliseconds = td.total_milliseconds() -
    ((hours * 3600 + minutes * 60 + seconds) * 1000);

  char buf[40];
  sprintf(buf, "%02ld:%02ld:%02ld.%03ld",
	  hours, minutes, seconds, milliseconds);

  return buf;
}

namespace qi = boost::spirit::qi;
namespace ascii = boost::spirit::ascii;

using namespace std;
using namespace tbb;

struct HashCompare {
    static size_t hash( std::string x ) {
    return x.length();
  }
    static bool equal( std::string x, std::string y ) {
    return x==y;
  }
};

typedef concurrent_hash_map<std::string, int, HashCompare> TimeStamp_msec;
static TimeStamp_msec timestamp_msec;    

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

  int linecounter = 0;
  
  ifstream ifs(argv[1], ios::in);
  if(!ifs){
    cerr << "Error: file not opened." << endl;
    return 1;
  }

  string tmp;
  while(getline(ifs, tmp)){
    const std::string str = tmp;
    
    boost::any result;
    if(qi::phrase_parse(str.begin(), str.end(), p, ascii::space, result))
      {
	std::map<std::string, boost::any> p = boost::any_cast<std::map<std::string, boost::any>>(result);

	/*
	  std::cout << boost::any_cast<std::string>(p["capture_time"]) << ",";
	  std::cout << boost::any_cast<std::string>(p["source_ip"]) << std::endl;
	*/

        std::string timestamp_string =  boost::any_cast<std::string>(p["capture_time"]);

        TimeStamp_msec::accessor a;
        timestamp_msec.insert(a, timestamp_string);
        a->second += 1;

	if(linecounter%10000==0)
	  std::cout << "[" << now_str() << "] " << linecounter << " lines - done." << endl;
	
      }

    linecounter++;
    
  }

  ifs.close();

    for( TimeStamp_msec::iterator i=timestamp_msec.begin(); i!=timestamp_msec.end(); ++i )
      {
	    cout << i->first << "," << i->second << endl;
      }                         

  return 0;
}
