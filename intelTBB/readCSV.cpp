#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <boost/tokenizer.hpp>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"

std::vector < std::vector< std::string > > parse_csv(const char* filepath)
{
    std::vector< std::vector< std::string > > cells;
    std::string line;
    std::ifstream ifs(filepath);

    while (std::getline(ifs, line)) {

        std::vector< std::string > data;

        // 1行を走査
        boost::tokenizer< boost::escaped_list_separator< char > > tokens(line);
        for (const std::string& token : tokens) {
            data.push_back(token);
        }

        // 1行読み込んだ結果を入れる
        cells.push_back(data);
    }

    return cells;
}

int main(int argc, char *argv[])
{
    int counter = 0;
  
    const auto cells = parse_csv(argv[1]);
    for (const auto& rows : cells) {

      counter = 0;
      
        for (const auto& cell : rows) {
	  // std::cout << "<" << cell << "> " << std::endl;

	  if(counter == 4)
	    std::cout << cell << std::endl;

	  if(counter == 7)
	    std::cout << cell << std::endl;

	  counter++;
	  
        }
        // std::cout << std::endl;
    }

    return 0;
}
