#include<iostream>
#include<algorithm>
#include<iomanip>
#include<time.h>
#include<thrust/host_vector.h>
#include<thrust/device_vector.h>
#include<thrust/sort.h>

#define N (8<<10)
#define C1 10000

template<class T>
class plusOne{
public:
    __device__ __host__ T operator() (T a){
        return a+1;
    }
};

int main(){
    srand(time(NULL));
    thrust::host_vector<int> hv(N);
    std::generate(hv.begin(),hv.end(),rand);
    thrust::device_vector<int> dv=hv;

    cudaEvent_t start,stop;
    float elapsed;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);


    cudaEventRecord(start,0);
    for(int c=0;c<C1;c++){
        thrust::transform(dv.begin(),dv.end(),dv.begin(),plusOne<int>());
    }
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed,start,stop);

    std::cout<<"gpu :"<<elapsed<<"ms ["<<std::setprecision(8)<<C1/elapsed<<"/ms]"<<std::endl;

    std::generate(hv.begin(),hv.end(),rand);
    dv=hv;

    cudaEventRecord(start,0);
    for(int c=0;c<C1;c++){
        thrust::transform(hv.begin(),hv.end(),hv.begin(),plusOne<int>());
    }
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed,start,stop);

    std::cout<<"cpu :"<<elapsed<<"ms ["<<std::setprecision(8)<<C1/elapsed<<"/ms]"<<std::endl;

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
