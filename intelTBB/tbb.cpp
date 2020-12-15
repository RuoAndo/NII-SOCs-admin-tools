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

using namespace std;
using namespace tbb;

typedef tbb::concurrent_hash_map<string, string> iTbb_addr_pair;
static iTbb_addr_pair Tbb_Addr_Pair; 

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

    std::string src_ipAddr;
    std::string dest_ipAddr;

    const auto cells = parse_csv(argv[1]);
    for (const auto& rows : cells) {

        counter = 0;
        for (const auto& cell : rows) {
	  // std::cout << "<" << cell << "> " << std::endl;
	  
	  if(counter == 4)
	    {
	      // std::cout << cell << std::endl;
             src_ipAddr = string(cell);
            }

	  if(counter == 7)
	    {
	      // std::cout << cell << std::endl;
             dest_ipAddr = string(cell);
            }

          iTbb_addr_pair::accessor t;
	  Tbb_Addr_Pair.insert(t, src_ipAddr);
	  t->second = dest_ipAddr;

	  counter++;
	  
        }
	
        // std::cout << std::endl;
    }

    counter = 0;
    for(auto itr = Tbb_Addr_Pair.begin(); itr != Tbb_Addr_Pair.end(); ++itr) {
      if(counter > 0)
	std::cout << counter << ":" << itr->first << "," << itr->second << std::endl;
      counter++;
    }
    
    return 0;
}
