if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" == "" ];
then
    echo "argument required: ./do-list.sh listfile dir title"
fi

\mv list-* reduced/
\mv reduce-* reduced/

while read line; do
    echo "searching " $line "..." 
    ./do.sh $line $2 $3
done < $1
