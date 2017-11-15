# auto

mkdir outs
mv out* outs/

./do.sh IPADDR DIR<outs>
<pre>
cd ./traverse2
make
cd ..

time ./traverse2/traverse2 $1 $2 > tmp

time ./reduce.sh tmp
time pig reduce2.pig > tmp2

python clean.py tmp2 > tmp3
./drem.pl tmp3 > tmp4

python cut.py tmp4 $1

</pre>

<pre>
if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" == "" ];
then
    echo "argument required: ./do-list.sh listfile dir title"
fi

while read line; do
    echo "searching " $line "..." 
    ./do.sh $line $2 $3
done < $1
</pre>

<pre>
ls list-* > listlist
time ./cat-list.sh listlist
more list-all 
</pre>