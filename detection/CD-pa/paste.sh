ls pa-* > palist
./sort-palist.pl palist > palist-sorted

while read line; do
    constr=$constr" "$line
done < palist-sorted

echo $constr
paste -d"," $constr > tmp
