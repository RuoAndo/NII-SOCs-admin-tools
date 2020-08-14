#include <iostream>
#include <string>
#include <vector>
#include <boost/spirit.hpp>
//#include <boost/spirit/include/classic.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lambda/bind.hpp>
using namespace std;
using namespace boost::spirit;

struct IntList2 : grammar<IntList2>
{
    IntList2( vector<int>& vi ) : storage(vi) {}
    vector<int>& storage;

    template<typename ScannerT>
      struct definition
      {
          typedef rule<ScannerT> rule_t;
          rule_t r;
          definition( const IntList2& self )
          {
              using namespace boost::lambda;
              r = int_p[ bind(&vector<int>::push_back,&var(self.storage),_1) ] % ',';
          }
          const rule_t& start() const { return r; }
      };
};

int main()
{
    for( string line; cout<<"# ", getline(cin, line); )
    {
        vector<int> v;
        if( parse( line.begin(), line.end(), IntList2(v) ).full )
            cout << "the number of numbers - " v.size() << endl;
    }
    return 0;
}
