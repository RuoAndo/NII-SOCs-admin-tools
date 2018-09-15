#include <iostream>
#include <bitset>

int main()
{
  // 整数から8ビットのビット集合を構築
  std::bitset<8> bs1(131uL); // 10000011

  // 文字列から8ビットのビット集合を構築
  // std::bitset<8> bs2("10000011");
  std::bitset<8> bis2(std::string("10101010"));

  // 1ビット目が1かを判定
  if (bs1[1]) {
    std::cout << "1st bit is 1" << std::endl;
  }

  // 2ビット目を1にする
  bs1.set(2);
  std::cout << "2nd bit to 1 : " << bs1 << std::endl;

  // 2ビット目を0に戻す
  bs1.reset(2);

  // いずれかのビットが1かを判定
  if (bs1.any()) {
    std::cout << "some bits are 1" << std::endl;
  }

  // 論理演算
  std::bitset<8> and_bits = bs1 & std::bitset<8>(std::string("10000001")); // 論理積
  std::bitset<8> or_bits  = bs1 | std::bitset<8>(std::string("00010100")); // 論理和
  std::bitset<8> xor_bits = bs1 ^ std::bitset<8>(std::string("00100011")); // 排他的論理和

  std::cout << "and : " << and_bits << std::endl;
  std::cout << "or  : " << or_bits << std::endl;
  std::cout << "xor : " << xor_bits << std::endl;
}
