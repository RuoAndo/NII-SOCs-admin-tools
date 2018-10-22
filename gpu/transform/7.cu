#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/copy.h>
#include <thrust/transform.h>
#include <iostream>
#include<algorithm>
#include<iomanip>
#include<time.h>

struct sample_functor {
  double alpha;
  double beta;

  sample_functor(double _alpha, double _beta) {
    alpha = _alpha;
    beta = _beta;
  }

  __device__ double operator() (const double& x, const double& y) const {
    return alpha * x + (1.0 - alpha) * (beta * y);
  }
};

int main() {

  int N = 1024 << 20;

  std::cout << "vector size:" << N << std::endl;

  srand(time(NULL));
    
  thrust::host_vector<int> host_x(N);
  std::generate(host_x.begin(),host_x.end(),rand);
  thrust::device_vector<int> device_x=host_x;

  thrust::host_vector<int> host_y(N);
  std::generate(host_y.begin(),host_y.end(),rand);
  thrust::device_vector<int> device_y=host_y;

  /*
  thrust::host_vector<double> host_x{1.1, 3.3, 2.2};
  thrust::host_vector<double> host_y{6.6, 7.7, 8.8};
  thrust::host_vector<double> host_output(3);
  thrust::device_vector<double> device_x(3);
  thrust::device_vector<double> device_y(3);
  thrust::device_vector<double> device_output(3);
  */

  thrust::host_vector<double> host_output(N);
  thrust::device_vector<double> device_output(N);
  
  double alpha = 0.005;
  double beta = 0.1;

    cudaEvent_t start,stop;
    float elapsed;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start,0);

  thrust::copy(host_x.begin(), host_x.end(), device_x.begin());
  thrust::copy(host_y.begin(), host_y.end(), device_y.begin());

  thrust::transform(device_x.begin(), device_x.end(), device_y.begin(), device_output.begin(), sample_functor(alpha, beta));

  thrust::copy(device_output.begin(), device_output.end(), host_output.begin());

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed,start,stop);

    std::cout<<"gpu :"<<elapsed<<"ms ["<<std::setprecision(8)<<elapsed<<"/ms]"<<std::endl;

  std::cout << host_output[0] << ", " << host_output[1] << ", " << host_output[2] << std::endl;
  // 0.6622, 0.78265, 0.8866000000000002

  return 0;
}
