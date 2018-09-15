#include <iostream>
#include <bitset>

int main()
{
  std::bitset<8> bs1(131uL); // 10000011

  std::bitset<8> bis2(std::string("10101010"));

  if (bs1[1]) {
    std::cout << "1st bit is 1" << std::endl;
  }

  bs1.set(2);
  std::cout << "2nd bit to 1 : " << bs1 << std::endl;

  bs1.reset(2);

  if (bs1.any()) {
    std::cout << "some bits are 1" << std::endl;
  }

  std::bitset<8> or_bits  = bs1 | std::bitset<8>(std::string("00010100"));
  std::bitset<8> xor_bits = bs1 ^ std::bitset<8>(std::string("00100011")); 

  std::cout << "and : " << and_bits << std::endl;
  std::cout << "or  : " << or_bits << std::endl;
  std::cout << "xor : " << xor_bits << std::endl;
}
