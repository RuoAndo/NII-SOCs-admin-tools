r=`locate piggybank.jar`
r2=`echo $r | cut -d " " -f 1`
echo "copy " $r2 " to here"
cp $r2 .

