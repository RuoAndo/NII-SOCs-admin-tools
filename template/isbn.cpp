#include <iostream>
#include <boost/spirit.hpp>

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

        std::cout <<  
                parse(argv[1],
                        str_p("ISBN") >>
                        (str_p("978") | str_p("979")) >>
                        ch_p('-') >>
                        uint_p >>
                        ch_p('-') >>
                        uint_p >>
                        ch_p('-') >>
                        uint_p >>
                        ch_p('-') >>
                        (digit_p | ch_p('X')) >>
                        end_p
                ).full
        << std::endl; 

        return 0;
}

