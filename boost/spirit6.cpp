#include <iostream>
#include <string>
#include <stack>
#include <boost/spirit.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lambda/bind.hpp>
using namespace std;
using namespace boost::spirit;

// using stack
template<typename Ite>
  class CalculatorT
  {
  public:
      double answer() const { return stk.top(); }
      void set( double d ) { stk.push(d); }
      void add( Ite, Ite ) { double y=tp(), x=tp(); stk.push(x+y); }
      void sub( Ite, Ite ) { double y=tp(), x=tp(); stk.push(x-y); }
      void mul( Ite, Ite ) { double y=tp(), x=tp(); stk.push(x*y); }
      void div( Ite, Ite ) { double y=tp(), x=tp(); stk.push(x/y); }
  private:
      stack<double> stk;
      double tp() { double d = stk.top(); stk.pop(); return d; }
  };
typedef CalculatorT<string::const_iterator> Calc;

struct CalcGrammar : grammar<CalcGrammar>
{
    CalcGrammar( Calc& c ) : cal(c) {}
    Calc& cal;

    template<typename ScannerT>
      struct definition
      {
          typedef rule<ScannerT> rule_t;
          rule_t expr, fctr, term;
          definition( const CalcGrammar& self )
          {
              using namespace boost::lambda;
              var_type<Calc>::type cal( var(self.cal) );

              expr = term >> *( ('+'>>term)  [ bind(&Calc::add,cal,_1,_2) ]
                              | ('-'>>term)  [ bind(&Calc::sub,cal,_1,_2) ] );
              term = fctr >> *( ('*'>>fctr)  [ bind(&Calc::mul,cal,_1,_2) ]
                              | ('/'>>fctr)  [ bind(&Calc::div,cal,_1,_2) ] );
              fctr = real_p                  [ bind(&Calc::set,cal,_1)    ]
                   | '(' >> expr >> ')';
          }
          const rule_t& start() const { return expr; }
      };
};

int main()
{
    for( string s; cout<<"# ", getline(cin, s); )
    {
        Calc cal;
        if( parse( s.begin(), s.end(), CalcGrammar(cal), space_p ).full )
            cout << cal.answer() << endl;
    }
    return 0;
}
