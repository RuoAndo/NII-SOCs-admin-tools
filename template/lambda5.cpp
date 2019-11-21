#include<boost/spirit/include/qi.hpp>
#include<string>
#include<iostream>

namespace qi = boost::spirit::qi;

int main(){
  using qi::int_;
  using qi::parse;
  using qi::char_;
  {
    std::string str("{46}");
    std::string::iterator first = str.begin(), last = str.end();
    
    auto w = [](int x){std::cout << x << std::endl;};

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
	auto w = [](int x){std::cout << x << std::endl;};
    
	parse(
	      first,
	      last,
	      char_('"') >>
	      int_[w] 
	      );
    
 
  }
  return 0; 
}

