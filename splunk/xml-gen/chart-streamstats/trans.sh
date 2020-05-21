if [ $# != 5 ]; then
        echo "usage: ./trans.sh [XML file name] [ingress file path] [egress file path] [XML file title]"
	exit 1
fi

echo $2 | sed -e "s/\//\\\\\//g" > buffer
str2=`cat buffer`

echo $3 | sed -e "s/\//\\\\\//g" > buffer
str3=`cat buffer`

str4=$4

str5=$5

#while read line; do
        cat $1 | perl -0pe s/IIIII/${str2}/g | perl -0pe s/EEEEE/${str3}/g | perl -0pe s/HHHHH/${str4}/g | perl -0pe s/NNNNN/${str5}/g;
#done < $1
