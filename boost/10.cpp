#include <string>
#include <boost/spirit/include/phoenix.hpp>
#include <boost/spirit/include/qi.hpp>

using std::string;

using boost::spirit::qi::grammar;
using boost::spirit::qi::rule;
using boost::spirit::qi::space_type;
using boost::spirit::qi::skip_flag;
using boost::spirit::unused_type;

namespace qi = boost::spirit::qi;
namespace phx = boost::phoenix;

struct make_line_impl
{
  int* _context;
  make_line_impl(int* context)
  {
    _context = context;
  }

  template <typename Arg> struct result { typedef int* type; };

  template <typename Arg>
  int* operator()(Arg const & content) const
  {
    return new int(5);
  }
};


template<typename Iterator>
struct MyGrammar : grammar<Iterator, unused_type, space_type>
{
  rule<Iterator, unused_type, space_type> start;
  rule<Iterator, int*(), space_type> label;
  rule<Iterator, string*(), qi::locals<int*>, space_type> line;

  MyGrammar() : MyGrammar::base_type(start)
  {
    make_line_impl mlei(new int(5));
    phx::function<make_line_impl> make_line(mlei);

    start = *(line);

    line = label[qi::_a = make_line(qi::_1)];
  }
};


int main(int argc, char **argv) {

  string contents;

  qi::phrase_parse(contents.begin(), contents.end(), MyGrammar<string::iterator>(), space_type(), skip_flag::postskip);
    return 0;
}

