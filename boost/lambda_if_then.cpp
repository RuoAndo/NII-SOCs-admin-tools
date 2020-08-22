#include <boost/lambda/lambda.hpp>
#include <boost/lambda/if.hpp>
#include <vector>
#include <algorithm>
#include <iostream>

int main()
{
  std::vector<int> v{1, 3, 2, 0, 4, 5, 2};
  std::for_each(v.begin(), v.end(),
    boost::lambda::if_then(boost::lambda::_1 > 2,
    std::cout << boost::lambda::_1 << "\n"));
}
