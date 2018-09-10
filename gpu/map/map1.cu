#include<iostream>
#include<algorithm>
#include<iomanip>
#include<time.h>
#include<thrust/host_vector.h>
#include<thrust/device_vector.h>
#include<thrust/sort.h>
#include <thrust/iterator/permutation_iterator.h>

#define N (8<<27)
#define M N/10

template<class T>
class plusOne{
public:
    __device__ __host__ T operator() (T a){
        return a+1;
    }
};

int f()
{
	srand(time(NULL));
	return rand() % 1000;
}

int main(){
    printf("size %d \n",N);
    
    srand(time(NULL));
    thrust::host_vector<int> source(N);
    std::generate(source.begin(),source.end(),rand);
    thrust::device_vector<int> dsource=source;

    thrust::host_vector<int> map(M);

    /*
    map[0] = 3;
    map[1] = 1;
    map[2] = 0;
    map[3] = 5;
    */
    
    std::generate(map.begin(),map.end(),f);
    thrust::device_vector<int> dmap=map;
    
    cudaEvent_t start,stop;
    float elapsed;
    
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start,0);
    int sum = thrust::reduce(thrust::make_permutation_iterator(dsource.begin(), dmap.begin()), thrust::make_permutation_iterator(dsource.begin(), dmap.end()));
    std::cout << "sum :" << sum << std::endl;
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed,start,stop);

    std::cout<<"gpu :"<<elapsed<<"ms"<<std::endl;

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
