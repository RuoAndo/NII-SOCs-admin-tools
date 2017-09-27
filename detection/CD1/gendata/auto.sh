#rm rnn_10034; python 20.py in_10034 instlist 

while read line; do
    cut=`echo $line | cut -d "_" -f 2`
    rm -rf rnn_$cut; python 20.py in_$cut instlist
done < $1

