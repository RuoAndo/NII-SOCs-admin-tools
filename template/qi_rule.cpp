#include <iostream>
#include<boost/spirit/include/qi.hpp>
#include "csv.hpp"

using namespace boost::spirit;
using namespace std;

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
    
    // std::string timestamp = rec[0];
    // cout << timestamp << endl;
    
    std::string sessionID = rec[6];
    std::string packets_received = rec[7];

    for(size_t c = sessionID.find_first_of("\""); c != string::npos; c = c = sessionID.find_first_of("\"")){
      sessionID.erase(c,1);
    }
      
    for(size_t c = packets_received.find_first_of("\""); c != string::npos; c = c = packets_received.find_first_of("\"")){
      packets_received.erase(c,1);
    }
      
    cout << sessionID << "," << packets_received << endl;
  }

  return 0;
}

