rm -rf a.out
#g++ -c csv.cpp -std=c++11
#/usr/local/cuda-9.2/bin/nvcc -g -o $1 csv.o $1.cu -std=c++11 -ltbb

#g++ -c csv.cpp -std=c++11
nvcc -g -o $1 $1.cu -std=c++11 -lpthread -ltbb #--fpermissive
#/usr/local/cuda-9.2/bin/nvcc -g -o $1 $1.cu -lpthread -lpthread
