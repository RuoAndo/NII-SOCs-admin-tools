#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <boost/tokenizer.hpp>

#include <boost/spirit.hpp>
using namespace std;
using namespace boost::spirit;

struct MyGrammar : grammar<MyGrammar>
{
    template<typename ScannerT>
      struct definition
      {
          typedef rule<ScannerT> rule_t;
          rule_t r;

          definition( const MyGrammar& )
          {
	    // r = ch_p('a') >> *ch_p('b') >> ch_p('c');
	    // r = ch_p('a') >> *ch_p('b') >> ch_p('c');
	    // r = int_p; // >> +( '*' >> int_p );
	    r = int_p >> '.' >> int_p >> '.' >> int_p >> '.' >> int_p; ; // >> +( '*' >> int_p );
	    //r = int_p >> +( '*' >> int_p );
	    //r = repeat_p(2,4)[upper_p] % ',';
          }

          const rule_t& start() const { return r; }
      };
};

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
    MyGrammar parser;

    for (const auto& rows : cells) {
        for (const auto& cell : rows) {
	    // std::cout << "<" << cell << "> " << std::endl;

            // parsing one line
            parse_info<string::const_iterator> info =
            parse( cell.begin(), cell.end(), parser );
            // ternary operator)
	    if(info.full)
	      cout << "OK:" << cell << endl;
	    
	    // cout << (info.full ? "OK" : "fail") << endl;
	    
        }
        // std::cout << std::endl;
    }

    return 0;
}

