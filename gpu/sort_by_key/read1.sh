rm -rf a.out
g++ -c csv.cpp -std=c++11
/usr/local/cuda-9.2/bin/nvcc -o read1 csv.o read1.cu -std=c++11 -ltbb
