rm -rf a.out
g++ -c csv.cpp -std=c++11
nvcc csv.o gpu-cut-2.cu -std=c++11 -ltbb
