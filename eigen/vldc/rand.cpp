#include <random>
#include <stdio.h>
#include <stdlib.h>

#include <string>
#include <iostream>
#include <fstream>

using namespace std;

int main()
{
    std::random_device rnd;
    int tmp;
    
    for (int i = 0; i < 10; ++i) {
      tmp = rnd() % 10;
      std::cout << tmp << "\n";
    }
    getchar();
    return 0;
}

