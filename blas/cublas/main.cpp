#include <iostream>
#include <iomanip>
#include <sstream>
#include <sys/time.h>
#include <sys/types.h>
#include <string>
#include <cstdint>
#include <cstdlib>
#include <ctime>

#include "mulmat.hpp"

uint64_t getus() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec*1E6 + tv.tv_usec;
}

uint64_t temp_t;
void printTime(void) {
    uint64_t end_t = getus();
    //std::cout << std::setw(8) << (temp_t - end_t) << " [us]" << std::endl;
    std::cout << (end_t - temp_t) << " [us]" << std::endl;
    temp_t = end_t;
}

int main(int argc, char* argv[]) {

    struct timespec startTime, endTime, sleepTime;
  
    if(argc != 2 && argc != 4) {
        std::cout << "usage: ./a.out N or ./a.out M N K" << std::endl;
        return 1;
    }

    std::string::size_type sz = 0;
    std::string str;
    long M, N, K;
    if (argc == 2) {
        str = std::string(argv[1]);
        N = std::stol(str, &sz, 0);
        M = K = N;
    } else if (argc == 4){
        str = std::string(argv[1]);
        M = std::stol(str, &sz, 0);
        str = std::string(argv[2]);
        N = std::stol(str, &sz, 0);
        str = std::string(argv[3]);
        K = std::stol(str, &sz, 0);
    }

    std::cout << "(M,N,K)=(" << M << "," << N << "," << K << ")" << std::endl;

    temp_t = getus();

    float alpha, beta;
    alpha = beta = 1.0;

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    std::cout << "constructor : ";
    MulMat mm(M, N, K, alpha, beta);

    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");
    
    // printTime();

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    std::cout << "initialize  : ";
    mm.initialize();
    // printTime();
    
    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    std::cout << "cblas_sgemm : ";
    mm.multiply();
    // printTime();

    clock_gettime(CLOCK_REALTIME, &endTime);    
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");

    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    std::cout << "memoryFree  : ";
    mm.memoryFree();
    // printTime();

    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	     ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec
	     ,endTime.tv_nsec - startTime.tv_nsec);
    }
    printf(" sec\n");
    
    return 0;
}
