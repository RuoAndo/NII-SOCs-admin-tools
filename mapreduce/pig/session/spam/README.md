<pre>
# pig spam2.pig > tmp
# python clean.py tmp > tmp2
# python check.py tmp2
# ./drem.pl tmp2 > tmp3
# wc -l tmp3                                               
534429 tmp3
</pre>