#include <iostream>
#include <string>
#include <boost/spirit.hpp>
using namespace std;
using namespace boost::spirit;

void print_int( int x ) { cout << "you typed the figure - " << x << endl; }

struct IntList : grammar<IntList>
{
    template<typename ScannerT>
      struct definition
      {
          typedef rule<ScannerT> rule_t;
          rule_t r;
          definition( const IntList& )
          {
              r = int_p[&print_int] % ',';
          }
          const rule_t& start() const { return r; }
      };
};

int main()
{
    // generating the parser based on IntList
    IntList parser;

    // reading one line
    string line;
    while( cout<<"# ", getline(cin, line) )
    {
        // syntax analysis
        parse_info<string::const_iterator> info =
            parse( line.begin(), line.end(), parser, space_p );
        // ternary condition for checking the completion of parsing
        cout << (info.full ? "OK" : "fail") << endl;
    }   // repeat until EOF
    return 0;
}
