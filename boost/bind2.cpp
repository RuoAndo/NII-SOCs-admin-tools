#include <iostream>
#include <boost/bind.hpp>
using namespace std;
using namespace boost;

void func_for_bind( const char* s1, const char* s2,
               const char* s3, const char* s4 )
{
    cout << s1 << ' ' << s2 << ' '
         << s3 << ' ' << s4 << endl;
}

int main()
{
    // placeholder: _1, _2 
    bind( &func_for_bind, _1, _2, "three", "four" )( "one", "two" );
    bind( &func_for_bind, "one", _1, "three", _2 ) ( "two", "four" );
    bind( &func_for_bind, _1, _1, "m(..)m", _2 )( "(T_T)", "(^^)" );

    return 0;
}
