#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <boost/tokenizer.hpp>


std::vector < std::vector< std::string > > parse_csv(const char* filepath)
{
    std::vector< std::vector< std::string > > cells;
    std::string line;
    std::ifstream ifs(filepath);

    // csvを走査
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



// int main(void)
int main(int argc, char *argv[])
{
    const auto cells = parse_csv(argv[1]);
    for (const auto& rows : cells) {
        for (const auto& cell : rows) {
            std::cout << "<" << cell << "> " << std::endl;
        }
        std::cout << std::endl;
    }

    return 0;
}

