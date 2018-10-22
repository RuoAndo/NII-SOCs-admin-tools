#include <vector>
#include <iostream>
#include<algorithm>
#include<iomanip>
#include<time.h>

#include <thrust/transform.h>
#include <thrust/functional.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/copy.h>

using namespace std;
using namespace thrust;

template<class T>
struct saxpi{
    T k1;
    T k2;
    saxpi(T _k1, T _k2){
        k1=_k1;
        k2=_k2;
    }
    __host__ __device__ T operator()(T &x) const{
        return x*k1+k2;
    }
};


int main(void)
{
    int N = 1000000000;

    std::cout << "vector size:" << N << std::endl;

    float kk1=1, kk2=5;
    
    /*
    vector<float> vh = { 0, 1, 2, 3, 4, 5, 6, 7 };
    device_vector<float> v = vh;
    device_vector<float> v_out(v.size());
    */

    thrust::host_vector<float> vh(N);
    std::generate(vh.begin(),vh.end(),rand);
    thrust::device_vector<float> v=vh;
    thrust::device_vector<float> v_out(N);

    cout<<"Lambda:"<<endl;
    auto ff = [=]  __device__ (float x) {return kk1*x +kk2;};

    thrust::transform(v.begin(),v.end(),v_out.begin(),ff);

    for (size_t i = 0; i < 10; i++)
        std::cout << v_out[i] << std::endl;

/*
    cout<<"Functor:"<<endl;
    saxpi<float> f(kk1,kk2);
    v_out.clear();
    v_out.resize(v.size());
    thrust::transform(v.begin(),v.end(),v_out.begin(),f);

    for (size_t i = 0; i < 10; i++)
            std::cout << v_out[i] << std::endl;
*/

}

