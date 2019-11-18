#if __linux__ && defined(__INTEL_COMPILER)
#define __sync_fetch_and_add(ptr,addend) _InterlockedExchangeAdd(const_cast<void*>(reinterpret_cast<volatile void*>(ptr)), addend)
#endif
#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>   
#include "utility.h"

#include "csv.hpp"

using namespace std;

int main( int argc, char* argv[] ) {

  int counter = 0;
  
  int N = atoi(argv[3]);  
  int netmask;

  std::map <int,int> found_flag;
  	
  const string session_file = std::string(argv[2]); 
  vector<vector<string>> session_data; 
	  
  try {
    Csv objCsv(session_file);
    if (!objCsv.getCsv(session_data)) {
      cout << "read ERROR" << endl;
      return 1;
    }
  }
  catch (...) {
    cout << "EXCEPTION (session)" << endl;
    return 1;
  }

  for (unsigned int row = 0; row < session_data.size(); row++) {
    vector<string> rec = session_data[row];
        return 0;
  }
}
