g++ -g -c $1.cpp csv.cpp -std=c++11 -ltbb -lpthread -fpermissive
g++ -g -o $1 $1.o csv.o  -std=c++11 -ltbb -fpermissive -lpthread
