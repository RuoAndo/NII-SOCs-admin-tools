#include <iostream>
#include <vector>
#include <algorithm>
#include <boost/lambda/lambda.hpp>
using namespace std;
using namespace boost;

int main()
{
    using namespace boost::lambda;

    int init_v[] = {-25,-15,0,25,15};
    vector<int> v( init_v, init_v+5 );


    for_each( v.begin(), v.end(), (cout << _1 << ',') );
    cout << endl;
    
    for_each( v.begin(), v.end(), (_1 += 13) );

    for_each( v.begin(), v.end(), (cout << _1 << ',') );
    cout << endl;
    
    vector<int>::iterator it =
        adjacent_find( v.begin(), v.end(), (_1 > _2) );
    cout << *it << " is more than " << *(it+1) << endl;

    replace_if( v.begin(), v.end(), (_1 < 0 || 20 < _1), 0 );

    for_each( v.begin(), v.end(), (cout << _1 << ' ') );
    cout << endl;

    return 0;
}
