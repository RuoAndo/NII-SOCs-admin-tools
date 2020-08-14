#include <iostream>
#include <string>
#include <boost/spirit.hpp>
using namespace std;
using namespace boost::spirit;

// calculator grammar
struct ArithCalc : grammar<ArithCalc>
{
    template<typename ScannerT>
      struct definition
      {
          typedef rule<ScannerT> rule_t;
          rule_t expr, fctr, term;

          definition( const ArithCalc& )
          {
              expr = term >> *('+'>>term | '-'>>term);
              term = fctr >> *('*'>>fctr | '/'>>fctr);
              fctr = real_p | '('>>expr>>')';
          }

          const rule_t& start() const { return expr; }
      };
};

int main()
{
    // generating parser 
    ArithCalc parser;

    // reading one line
    string line;
    while( cout<<"# ", getline(cin, line) )
    {
        // parsing one line
        parse_info<string::const_iterator> info =
            parse( line.begin(), line.end(), parser, space_p );
        // ternary operator
        cout << (info.full ? "OK" : "fail") << endl;
    }   // repeat until EOF is input
    return 0;
}
