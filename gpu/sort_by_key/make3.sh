rm -rf a.out
g++ -c csv.cpp -std=c++11
/usr/local/cuda-9.1/bin/nvcc csv.o gpu-cut-3.cu -std=c++11 -ltbb
