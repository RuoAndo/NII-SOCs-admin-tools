#include <iostream>
#include <bitset>
int main()
{
  unsigned long value = 1234;
  std::cout << value << std::endl; 
  std::cout << std::bitset<32>(value) << std::endl;
  return 0;
}
