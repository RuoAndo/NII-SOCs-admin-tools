#include <iostream>
#include <string>
#include <vector>
#include <boost/spirit.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lambda/bind.hpp>
using namespace std;
using namespace boost::spirit;

struct Abc : grammar<Abc>
{
    struct MyAction
    {
        template<typename Ite>
          void operator()( Ite i1, Ite i2 ) const
            { cout << "# of characters:" << i2 - i1 << endl
                   << "content:" << string(i1,i2) << endl; }
    };

    template<typename ScannerT>
      struct definition
      {
          typedef rule<ScannerT> rule_t;
          rule_t r;
          definition( const Abc& self )
          {
              r = 'a' >> (*ch_p('b'))[MyAction()] >> 'c';
          }
          const rule_t& start() const { return r; }
      };
};

int main()
{
    for( string line; cout<<"# ", getline(cin, line); )
        if( parse( line.begin(), line.end(), Abc() ).full );
    return 0;
}
