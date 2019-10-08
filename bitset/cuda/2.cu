#include<iostream>
#include<algorithm>
#include<iomanip>
#include<bitset>

#include<time.h>
#include<thrust/host_vector.h>
#include<thrust/device_vector.h>
#include<thrust/sort.h>

// #define N (8<<10)
#define N 256
// #define C1 10000

template<class T>
class plusOne{
public:
    __device__ __host__ T operator() (T a){
        return a+1;
    }
};

int main(){
    srand(time(NULL));
    thrust::host_vector<int> V1(N);
    thrust::host_vector<int> V2(N);
    thrust::host_vector<int> V3(N);
    thrust::host_vector<int> V4(N);
    
    std::generate(V1.begin(),V1.end(),rand);
    thrust::fill(V2.begin(), V2.end(), 128);
    
    thrust::device_vector<int> DV1 = V1;
    thrust::device_vector<int> DV2 = V2;
    thrust::device_vector<int> DV3 = V3;

    thrust::transform(DV1.begin(), DV1.end(), DV2.begin(), DV3.begin(), thrust::bit_and<int>());

    for(int i = 0; i < 10; i++)
    {
            std::bitset<16> bs1(DV1[i]);
	    std::bitset<16> bs2(DV2[i]);
    	    std::cout << DV1[i] << "," << bs1 << "," << DV2[i] << "," << bs2 << "," << DV3[i] << std::endl;
    }

    thrust::sequence(V4.begin(), V4.end(), 128);
    thrust::device_vector<int> DV4 = V4;

    thrust::transform(DV4.begin(), DV4.end(), DV2.begin(), DV3.begin(), thrust::bit_and<int>());

    /*
    for(int i = 0; i < 129; i++)
    	    std::cout << DV4[i] << "," << DV2[i] << "," << DV3[i] << std::endl;
    */

    return 0;
}
