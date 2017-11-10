find . -maxdepth 1 -type d | grep dir_ | sed -e 's/\.\///g' > dirlist
#ls dir_* > dirlist

while read line; do
    echo "entering " $line "..."
    cd $line
    ./rename_and_do.sh > log_do_${line} 2>&1 &
    #./group6 log_group6_${line} 2>&1 &
    cd ..
done < dirlist
