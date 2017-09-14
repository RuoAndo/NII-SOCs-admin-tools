sed -e "1,4d" $1 > $1-cut
sed -e "1,4d" $2 > $2-cut
cat $1-cut $2-cut > tmp
