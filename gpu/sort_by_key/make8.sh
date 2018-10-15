rm -rf a.out
g++ -c csv.cpp -std=c++11
/usr/local/cuda-9.2/bin/nvcc -o gpu-cut-8 csv.o gpu-cut-8.cu -std=c++11 -ltbb
