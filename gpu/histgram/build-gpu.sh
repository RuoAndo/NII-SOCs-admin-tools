g++ -c csv.cpp -std=c++11
nvcc -g -o $1 csv.o $1.cu -std=c++11 --expt-extended-lambda -lcurand
