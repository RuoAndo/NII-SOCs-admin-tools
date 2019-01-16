#include <thrust/device_vector.h>
#include <thrust/for_each.h>

#include <curand.h>

#include <iterator>
#include <iostream>
#include <ctime>

int main() {
  using namespace std;

  const int N = 100000;
  thrust::device_vector<float> dscore(N);
  thrust::device_vector<int>   dhist(101, 0);

  { 
    curandGenerator_t gen;
    curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
    curandSetPseudoRandomGeneratorSeed(gen, static_cast<unsigned long long>(time(nullptr)));
    curandGenerateNormal(gen, dscore.data().get(), N, 50.30f, 15.0f);
    curandDestroyGenerator(gen);
  }

  int* histPtr = dhist.data().get(); 
  thrust::for_each(begin(dscore), end(dscore),
                   [=] __device__ (float val) -> void {
                     int i = static_cast<int>(val+0.5f); 
                     if ( i >= 0 && i <= 100 ) { 
                       atomicAdd(histPtr+i, 1); 
                     }
                   });
		   
  for ( int item : dhist ) {
    cout << item << endl;
  }
}
