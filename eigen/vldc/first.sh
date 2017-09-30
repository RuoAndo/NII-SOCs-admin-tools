LN=500000
<<<<<<< HEAD
nItems=5
=======
Nitems=5
>>>>>>> 816c3d96107606a7228acd00dbba2a6b1699daef

if [ "$1" = "" ]
then
    echo "argument required: ./first FILE_NAME"
    exit
fi

./build.sh rand-labeling
./build.sh avg
./build.sh relabel

#split -l $LN $1 out
ls out* > list
#head -n 20 list > list-20
#./rename.sh list-20
time ./rename.sh list
echo "now initlializing labels ..."
<<<<<<< HEAD
time ./rand-labeling $LN $nItems
=======

# data size is LN * Nitems (500000 * 5)
time ./rand-labeling $LN $Nitems
>>>>>>> 816c3d96107606a7228acd00dbba2a6b1699daef
