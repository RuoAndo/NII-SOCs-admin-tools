python cut.py $1 > $1-cut
./main $1-cut > $1-out
python diff1.py $1-out > $1-diff
python std.py $1-diff $1 instlist > $1-std
