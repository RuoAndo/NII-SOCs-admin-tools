#include <bitset>
#include <iostream>

typedef std::bitset<8> TestBitset;

int main()
{
    TestBitset bset(0xF0);  // 11110000
    
    std::cout << bset << std::endl;
    bset.set();

    std::cout << bset << std::endl;
}
