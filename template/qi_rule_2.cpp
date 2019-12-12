#include <iostream>
#include<boost/spirit/include/qi.hpp>
#include "csv.hpp"

using namespace boost::spirit;
using namespace std;

struct Result {
  long x;
  int y;
};
BOOST_FUSION_ADAPT_STRUCT(Result, x, y)

template <typename Iterator>
struct MyGrammar : public qi::grammar<Iterator, Result(), qi::space_type> {
  MyGrammar() : MyGrammar::base_type(expr) {
    expr = long_parser >> qi::lit(",") >> int_parser;
    long_parser = qi::long_;
    int_parser = qi::int_;
  }

  qi::rule<Iterator, Result(), qi::space_type> expr;
  qi::rule<Iterator, long(), qi::space_type> long_parser;
  qi::rule<Iterator, int(), qi::space_type> int_parser;
};

int main(int argc, char** argv) {


  int counter = 0;
  
  const string sfile = std::string(argv[1]); 
  vector<vector<string>> sdata; 
  
  try {
    Csv objCsv(sfile);
    if (!objCsv.getCsv(sdata)) {
      std::cout << "read ERROR" << std::endl;
      return 1;
    }
  }
  catch (...) {
    std::cout << "EXCEPTION (READ)" << std::endl;
    return 1;
  }
  
  for (unsigned int row = 0; row < sdata.size(); row++) {  
    vector<string> rec = sdata[row];
    

    string line_string;
    line_string.clear();
    for (auto itr = rec.begin(); itr != rec.end(); itr++){
      line_string = line_string + "," + string(*itr);
    }
      
    std::string sessionID = rec[6];
    std::string packets_received = rec[7];

    for(size_t c = sessionID.find_first_of("\""); c != string::npos; c = c = sessionID.find_first_of("\"")){
      sessionID.erase(c,1);
    }
      
    for(size_t c = packets_received.find_first_of("\""); c != string::npos; c = c = packets_received.find_first_of("\"")){
      packets_received.erase(c,1);
    }

    string str = sessionID + "," + packets_received;
    
    Result result;
    MyGrammar<std::string::iterator> parser;
    
    auto itr = str.begin(), end = str.end();
    qi::phrase_parse(itr, end, parser, qi::space, result);

    std::cout << line_string << std::endl;
    std::cout << result.x << ", " << result.y << std::endl;
    
    // cout << sessionID << "," << packets_received << endl;
  }

  return 0;
}

