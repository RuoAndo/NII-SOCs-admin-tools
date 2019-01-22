#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>
#include <random>

using namespace std;

int main()
{
  /*
    std::random_device rnd;     
    for (int i = 0; i < 10; ++i) {
        std::cout << std::hex << rnd() << "\n";
    }
  */

  std::random_device rnd;    
  std::mt19937 mt(rnd());    
  std::uniform_int_distribution<> rand100(0, 10);  
  for (int i = 0; i < 20; ++i) {
    std::cout << rand100(mt) << "\n";
  }
  
  return 0;
}
