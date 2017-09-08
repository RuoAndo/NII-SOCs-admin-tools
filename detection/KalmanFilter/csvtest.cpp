#include<iostream>
#include <fstream>

using namespace std;

int main()
{
  std::ifstream ifs("data");
  std::string str;
  while(getline(ifs,str))
    {
      cout<< str << endl;
    }

  return 0;
}
