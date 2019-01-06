rm -rf a.out
#/usr/local/cuda-9.2/bin/nvcc -g -o $1 csv.o $1.cu -std=c++11 -ltbb

#g++ -c csv.cpp -std=c++11
#/usr/local/cuda-9.2/bin/nvcc -g -o $1 $1.cu -lpthread -lpthread

#nvcc -g -o $1 $1.cu -std=c++11 -lpthread -ltbb #--fpermissive

g++ -c csv.cpp -std=c++11
nvcc -g -o $1 $1.cu csv.o -std=c++11 -lpthread -ltbb --expt-extended-lambda #--fpermissive
