#include <boost/spirit/include/qi.hpp>
#include <boost/spirit/include/phoenix.hpp>

int main()
{
    namespace qi = boost::spirit::qi;

    int a = 0, b = 0;

    const std::string s("3");
    bool f = qi::phrase_parse(s.begin(),s.end(),
            qi::int_[
                 boost::phoenix::ref(a)=1,
                 boost::phoenix::ref(b)=2
                ],
            qi::space);
    std::cout << f << ": a=" << a << ", b=" << b << std::endl;
}

