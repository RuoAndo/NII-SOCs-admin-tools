rm -rf a.out
g++ -c csv.cpp -std=c++11
/usr/local/cuda-9.2/bin/nvcc -g -o trans-matrix-1 csv.o trans-matrix-1.cu -std=c++11 -ltbb
