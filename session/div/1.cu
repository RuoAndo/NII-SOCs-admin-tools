#include<iostream>
#include<algorithm>
#include<iomanip>
#include<time.h>
#include<thrust/host_vector.h>
#include<thrust/device_vector.h>
#include<thrust/sort.h>

#define N (8<<10)
#define COUNT_LIMIT 10000

template<class T>
class plusOne{
public:
    __device__ __host__ T operator() (T a){
        return a+1;
    }
};

int main(){
    srand(time(NULL));
    thrust::host_vector<int> host_vector(N);
    std::generate(host_vector.begin(),host_vector.end(),rand);
    thrust::device_vector<int> device_vector=host_vector;

    cudaEvent_t start,stop;
    float elapsed;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);


    cudaEventRecord(start,0);
    for(int c=0;c<COUNT_LIMIT;c++){
        thrust::transform(device_vector.begin(),device_vector.end(),device_vector.begin(),plusOne<int>());
    }
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed,start,stop);

    std::cout<<"gpu :"<<elapsed<<"ms ["<<std::setprecision(8)<<COUNT_LIMIT/elapsed<<"/ms]"<<std::endl;

    std::generate(host_vector.begin(),host_vector.end(),rand);
    device_vector=host_vector;

    cudaEventRecord(start,0);
    for(int c=0;c<COUNT_LIMIT;c++){
        thrust::transform(host_vector.begin(),host_vector.end(),host_vector.begin(),plusOne<int>());
    }
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed,start,stop);

    std::cout<<"cpu :"<<elapsed<<"ms ["<<std::setprecision(8)<<COUNT_LIMIT/elapsed<<"/ms]"<<std::endl;

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
