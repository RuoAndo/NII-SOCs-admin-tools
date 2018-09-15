#include <iostream>
#include <bitset>

int main()
{
 
  std::bitset<8> bs1(131uL); // 10000011


  if (bs1[1]) {
    std::cout << "1st bit is 1" << std::endl;
  }

  bs1.set(2);
  std::cout << "2nd bit to 1 : " << bs1 << std::endl;

  bs1.reset(2);

  // いずれかのビットが1かを判定
  if (bs1.any()) {
    std::cout << "some bits are 1" << std::endl;
  }

}
