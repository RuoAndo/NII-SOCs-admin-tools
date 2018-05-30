#include <iostream>
#include <string>
#include <vector>
#include "csv.hpp"

using namespace std;

int main()
{
  const string csv_file = "all-1000"; 
  vector<vector<string>> data; 

  try {
    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
      cout << "read ERROR" << endl;
      return 1;
    }

    for (unsigned int row = 0; row < data.size(); row++) {
      vector<string> rec = data[row]; 
      for (unsigned int col = 0; col < rec.size(); col++) {
	cout << rec[col];
	if (col < rec.size() - 1) cout << ","; 
      }
      cout << endl;
    }
  }
  catch (...) {
    cout << "EXCEPTION!" << endl;
    return 1;
  }

  return 0;
}
