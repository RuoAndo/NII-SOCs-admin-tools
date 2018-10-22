#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/copy.h>
#include <thrust/transform.h>
#include <iostream>

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
  thrust::host_vector<double> host_x{1.1, 3.3, 2.2};
  thrust::host_vector<double> host_y{6.6, 7.7, 8.8};
  thrust::host_vector<double> host_output(3);
  thrust::device_vector<double> device_x(3);
  thrust::device_vector<double> device_y(3);
  thrust::device_vector<double> device_output(3);
  double alpha = 0.005;
  double beta = 0.1;

  thrust::copy(host_x.begin(), host_x.end(), device_x.begin());
  thrust::copy(host_y.begin(), host_y.end(), device_y.begin());

  thrust::transform(device_x.begin(), device_x.end(), device_y.begin(), device_output.begin(), sample_functor(alpha, beta));

  thrust::copy(device_output.begin(), device_output.end(), host_output.begin());

  std::cout << host_output[0] << ", " << host_output[1] << ", " << host_output[2] << std::endl;
  // 0.6622, 0.78265, 0.8866000000000002

  return 0;
}
