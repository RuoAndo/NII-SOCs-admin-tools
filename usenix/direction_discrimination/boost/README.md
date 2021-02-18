
<pre>
struct MyGrammar : grammar<MyGrammar>
{
    template<typename ScannerT>
      struct definition
      {
          typedef rule<ScannerT> rule_t;
          rule_t r;

          definition( const MyGrammar& )
          {
	    r = int_p >> '.' >> int_p >> '.' >> int_p >> '.' >> int_p; ; // >> +( '*' >> int_p );
          }

          const rule_t& start() const { return r; }
      };
};
</pre>

# Build and run.

<pre>
# ./build.sh multi_measure
</pre>

<pre>
# ls tmp-box/
xaa  xab  xac  xad  xae  xaf  xag  xah  xai  xaj
</pre>

<pre>
# cat list-sample
X.X.X.X,Y
</pre>

<pre>
# ./multi_measure tmp-box list-sample
</pre>
