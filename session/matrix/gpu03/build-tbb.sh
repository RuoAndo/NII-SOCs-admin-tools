rm -rf a.out
g++ -c csv.cpp -std=c++11
g++ -g -o $1 csv.o $1.cpp -std=c++11 -ltbb -fpermissive
