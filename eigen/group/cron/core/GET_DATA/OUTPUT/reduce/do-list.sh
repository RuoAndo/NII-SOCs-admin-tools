if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" == "" ];
then
    echo "argument required: ./do-list.sh listfile dir title"
fi

mkdir reduced

\mv list-* reduced/
\mv reduce-* reduced/

rm -rf list-*
rm -rf reduce-*

while read line; do
    echo "searching " $line "..." 
    /mnt/sdc/GET_DATA/OUTPUT/reduce/do.sh $line $2 $3
done < $1

/mnt/sdc/GET_DATA/OUTPUT/reduce/cat-list.sh $3 # yields list_all_$1_$today  
/mnt/sdc/GET_DATA/OUTPUT/reduce/cat-reduce.sh $3 # yields reduce_all
/mnt/sdc/GET_DATA/OUTPUT/reduce/iplist.sh reduce_all
