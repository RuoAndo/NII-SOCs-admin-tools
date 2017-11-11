rm -rf track-time
touch track-time

t1=`date "+%Y-%m-%d %H:%M:%S"`
echo $t1 >> track-time
 
./do.sh

find . -maxdepth 1 -type d | grep dir_ | sed -e 's/\.\///g' > dirlist

while read line; do
    echo "entering " $line "..."
    cd $line
    ./rename_and_do.sh > log_do_${line} 2>&1 &
    cd ..
done < dirlist

t2=`date "+%Y-%m-%d %H:%M:%S"`
echo $t2 >> track-time

diff=$(expr `date -d"$t2" +%s` - `date -d"$t1" +%s`)
echo "$diff"秒 >> track-time
#echo `expr "$diff" / 3600`時間
