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
#include <map>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "csv.hpp"
using namespace std;

int main( int argc, char* argv[] ) {

  int N = atoi(argv[2]);  

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data; 

  try {
      	  Csv objCsv(csv_file);
	  if (!objCsv.getCsv(data)) {
	    cout << "read ERROR" << endl;
	    return 1;
	    }

	  for (int row = 0; row < data.size(); row++) {
	    vector<string> rec = data[row]; 

	    // timestamp = rec[0];

	  }

   }
   catch (...) {
	  cout << "EXCEPTION!" << endl;
	  return 1;
   }

   return 0;
}
