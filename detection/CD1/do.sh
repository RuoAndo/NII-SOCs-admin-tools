./main data2 > out
python diff1.py out > d1
./sort.pl d1
python std.py d1 > s1
./sort.pl s1 > s2
head -n 20 s2
