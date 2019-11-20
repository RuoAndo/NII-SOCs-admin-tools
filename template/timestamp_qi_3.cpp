#include <iostream>
#include <boost/spirit.hpp>
#include "csv.hpp"

using namespace boost::spirit;
using namespace std;


int main(int argc, char** argv) {
        if (argc < 2) return 0;

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
	    
	    std::cout <<  
	      parse(timestamp.c_str(),
		    ch_p('"') >>
		    str_p("2019") >>
		    ch_p('/') >>
		    uint_p >>
		    ch_p('/') >>
		    uint_p >>
		    ch_p(' ') >>
		    uint_p >>
		    ch_p(':') >>
		    uint_p >>
		    ch_p(':') >>
		    uint_p >>
		    ch_p('"') >>
		end_p
                ).full
        << std::endl; 

	    
	}
       	  
	return 0;
}

