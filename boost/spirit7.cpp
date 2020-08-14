#include <iostream>
#include <string>
#include <boost/spirit.hpp>
using namespace std;
using namespace boost::spirit;

struct CalcGrammar2 : grammar<CalcGrammar2>
{
    CalcGrammar2( double& r ) : answer(r) {}
    double& answer;

    // cloure with val (double) 
    struct DoubleVal : closure<DoubleVal, double> { member1 val; };

    template<typename ScannerT>
      struct definition
      {
          rule<ScannerT>                      top;
          rule<ScannerT,DoubleVal::context_t> expr, fctr, term;

          definition( const CalcGrammar2& self )
          {
              using phoenix::arg1;
              top  = expr[ assign_a(self.answer) ];
              expr = term[ expr.val=arg1 ] >> *( '+'>>term[ expr.val+=arg1 ]
                                               | '-'>>term[ expr.val-=arg1 ] );
              term = fctr[ term.val=arg1 ] >> *( '*'>>fctr[ term.val*=arg1 ]
                                               | '/'>>fctr[ term.val/=arg1 ] );
              fctr = real_p[ fctr.val=arg1 ]
                   | '(' >> expr[ fctr.val=arg1 ] >> ')';
          }
          const rule<ScannerT>& start() const { return top; }
      };
};

int main()
{
    double r;
    for( string s; cout<<"# ", getline(cin, s); )
        if( parse( s.begin(), s.end(), CalcGrammar2(r), space_p ).full )
            cout << r << endl;
    return 0;
}
