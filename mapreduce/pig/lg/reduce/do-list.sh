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
    ./do.sh $line $2 $3
done < $1
