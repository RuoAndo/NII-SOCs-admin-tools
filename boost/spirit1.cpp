#include <iostream>
#include <string>
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
              r = ch_p('a') >> *ch_p('b') >> ch_p('c');
              //r = int_p >> +( '*' >> int_p );
              //r = repeat_p(2,4)[upper_p] % ',';
          }

          const rule_t& start() const { return r; }
      };
};

#include <typeinfo>
int main()
{
    MyGrammar parser;

    // input from keyboard
    string line;
    while( cout<<"# ", getline(cin, line) )
    {
      // parsing one line
        parse_info<string::const_iterator> info =
            parse( line.begin(), line.end(), parser );
      // ternary operator)
        cout << (info.full ? "OK" : "fail") << endl;
    } // repeat until EOF
    return 0;
}
