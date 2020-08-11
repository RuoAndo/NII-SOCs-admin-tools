#include <iostream>
#include <string>
#include <boost/spirit/include/qi.hpp>
#include <boost/fusion/include/struct.hpp>
#include <boost/bind.hpp>
#include <boost/range/algorithm/for_each.hpp>

namespace qi = boost::spirit::qi;

namespace client  {
    struct X {
        int value;
        double dval;
        std::string str;

        void print() const
        {
            std::cout << value << ": " << dval << ": " << str << std::endl;
        }
    };

    typedef qi::rule<std::string::const_iterator, client::X()> rule_type;

    template <class Parser, class Sequence>
    bool parse(const std::string& input, const Parser& p, Sequence& s)
    {
        return qi::parse(input.begin(), input.end(), p, s);
    }
}

BOOST_FUSION_ADAPT_STRUCT(
    client::X,
    (int, value)
    (double, dval)
    (std::string, str)
)

int main()
{
    const client::rule_type r = qi::int_ >> ", " >> qi::double_ >> ", " >> *(qi::char_ - qi::eol);

    const std::string s =
        "3, 1.23, Akira\n"
        "1, 5.26, Millia\r\n"
        "4, 2, Johnny\n";

    std::vector<client::X> v;
    if (!client::parse(s, r % qi::eol, v)) {
        std::cout << "failed" << std::endl;
        return 1;
    }

    boost::for_each(v, boost::bind(&client::X::print, _1));
}
