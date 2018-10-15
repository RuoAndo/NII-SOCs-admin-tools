rm -rf a.out
g++ -c csv.cpp -std=c++11
/usr/local/cuda-9.2/bin/nvcc csv.o gpu-cut-6.cu -std=c++11 -ltbb
