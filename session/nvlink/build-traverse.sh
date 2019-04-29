nvcc -g -c $1.cpp csv.cpp -std=c++11 -ltbb -Xcompiler="-fpermissive, -lpthread"
nvcc -g -c kernel.cu
nvcc -g -o $1 $1.o csv.o kernel.o -ltbb --generate-code arch=compute_60,code=sm_60
