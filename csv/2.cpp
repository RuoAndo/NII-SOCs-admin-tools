#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <boost/tokenizer.hpp>



std::vector < std::vector< std::string > > parse_csv(const char* filepath)
{

  using namespace std;

  /*
  std::vector< std::vector< std::string > > cells;
  std::string line;
  std::ifstream ifs(filepath);
  */

  /*
  while (std::getline(ifs, line)) {

    std::vector< std::string > data;

    boost::tokenizer< boost::escaped_list_separator< char > > tokens(line);
    for (const std::string& token : tokens) {
      data.push_back(token);
    }

    cells.push_back(data);
  }
  */

  // return cells;
}



int main(void)
{
  const auto cells = parse_csv("test.csv");
  for (const auto& rows : cells) {
    for (const auto& cell : rows) {
      std::cout << "<" << cell << "> " << std::endl;
    }
    std::cout << std::endl;
  }

  return 0;
}
