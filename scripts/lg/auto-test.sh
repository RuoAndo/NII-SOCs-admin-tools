python cut.py $1 > tmp

fn=`echo $1 | cut -d "/" -f 2`
echo $fn
\cp tmp $fn
