pyenv local system

d=6
n=10000000

nLines=`expr \( $d \* $n \) / 2`
echo $nLines

percent=`expr $nLines / 100`

rm gen-groupData.t.py

cat gen-groupData.py | sed "s/d = dCONSTANT/d = $d/" > gen-groupData.t1.py
cat gen-groupData.t1.py | sed "s/N = NCONSTANT/N = $n/" > gen-groupData.t.py

time python gen-groupData.t.py > tmp

split -l 1000000 tmp bk
ls bk* > list

COUNTER=0
while read line; do
    echo $line "->" $COUNTER
    cp $line $COUNTER
    COUNTER=`expr $COUNTER + 1`
done < list



