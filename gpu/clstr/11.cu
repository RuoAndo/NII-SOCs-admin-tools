#include <algorithm>
#include <cfloat>
#include <chrono>
#include <random>
#include <vector>

#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>
#include <random>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include "csv.hpp"
using namespace std;

// A small data structure to do RAII for a dataset of 2-dimensional points.
struct Data {
  explicit Data(int size) : size(size), bytes(size * sizeof(float)) {
    cudaMalloc(&x, bytes);
    cudaMalloc(&y, bytes);
  }

  Data(int size, std::vector<float>& h_x, std::vector<float>& h_y)
  : size(size), bytes(size * sizeof(float)) {
    cudaMalloc(&x, bytes);
    cudaMalloc(&y, bytes);
    cudaMemcpy(x, h_x.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(y, h_y.data(), bytes, cudaMemcpyHostToDevice);
  }

  ~Data() {
    cudaFree(x);
    cudaFree(y);
  }

  void clear() {
    cudaMemset(x, 0, bytes);
    cudaMemset(y, 0, bytes);
  }

  float* x{nullptr};
  float* y{nullptr};
  int size{0};
  int bytes{0};
};

__device__ float
squared_l2_distance(float x_1, float y_1, float x_2, float y_2) {
  return (x_1 - x_2) * (x_1 - x_2) + (y_1 - y_2) * (y_1 - y_2);
}

// In the assignment step, each point (thread) computes its distance to each
// cluster centroid and adds its x and y values to the sum of its closest
// centroid, as well as incrementing that centroid's count of assigned points.
__global__ void assign_clusters(const thrust::device_ptr<float> data_x,
                                const thrust::device_ptr<float> data_y,
                                int data_size,
                                const thrust::device_ptr<float> means_x,
                                const thrust::device_ptr<float> means_y,
                                thrust::device_ptr<float> new_sums_x,
                                thrust::device_ptr<float> new_sums_y,
                                int k,
                                thrust::device_ptr<int> counts,
				int* clusterNo) {
  const int index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index >= data_size) return;

  // int* clusterNo;

  // Make global loads once.
  const float x = data_x[index];
  const float y = data_y[index];

  float best_distance = FLT_MAX;
  int best_cluster = 0;
  for (int cluster = 0; cluster < k; ++cluster) {
    const float distance =
        squared_l2_distance(x, y, means_x[cluster], means_y[cluster]);
    if (distance < best_distance) {
      best_distance = distance;
      best_cluster = cluster;
      clusterNo[index] = best_cluster;
    }
  }

  atomicAdd(thrust::raw_pointer_cast(new_sums_x + best_cluster), x);
  atomicAdd(thrust::raw_pointer_cast(new_sums_y + best_cluster), y);
  atomicAdd(thrust::raw_pointer_cast(counts + best_cluster), 1);
}

// Each thread is one cluster, which just recomputes its coordinates as the mean
// of all points assigned to it.
__global__ void compute_new_means(thrust::device_ptr<float> means_x,
                                  thrust::device_ptr<float> means_y,
                                  const thrust::device_ptr<float> new_sum_x,
                                  const thrust::device_ptr<float> new_sum_y,
                                  const thrust::device_ptr<int> counts) {
  const int cluster = threadIdx.x;
  const int count = max(1, counts[cluster]);
  means_x[cluster] = new_sum_x[cluster] / count;
  means_y[cluster] = new_sum_y[cluster] / count;
}

int main(int argc, const char* argv[]) {
  // std::vector<float> h_x;
  // std::vector<float> h_y;

  // Load x and y into host vectors ... (omitted)

  int SHIFT = atoi(argv[1]);
  int k = 4;
  int number_of_iterations = 1000;

  int N = 1024 << SHIFT;
  cout << N << endl;
  
  std::vector<float> h_x(N);
  std::vector<float> h_y(N);
 
  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<> rand100(0, 99);
  std::uniform_int_distribution<> rand200(100, 199);
  std::uniform_int_distribution<> rand300(200, 299);
  std::uniform_int_distribution<> rand400(300, 399);  

  for(int i = 0; i < N; i++)
  {
	if (i % 4 == 0)
		h_x[i] = rand100(mt);
	if (i % 4 == 1)
		h_x[i] = rand200(mt);
	if (i % 4 == 2)
		h_x[i] = rand300(mt);
	if (i % 4 == 3)
		h_x[i] = rand400(mt);
		
	if (i % 4 == 0)
		h_y[i] = rand100(mt);
	if (i % 4 == 1)
		h_y[i] = rand200(mt);
	if (i % 4 == 2)
		h_y[i] = rand300(mt);
	if (i % 4 == 3)
		h_y[i] = rand400(mt);
  }

  /*
  int N = atoi(argv[2]);
  int k = 3;
  int number_of_iterations = 1000;

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data2; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data2)) {
     cout << "read ERROR" << endl;
     return 1;
  }

  for (int row = 0; row < 1024; row++) {
      vector<string> rec = data2[row]; 
      h_x.push_back(std::stof(rec[0]));
      h_y.push_back(std::stof(rec[1]));
  }
  */

  const size_t number_of_elements = h_x.size();

  int* h_clusterNo;
  h_clusterNo = (int *)malloc(N * sizeof(int)); 

  int* d_clusterNo;
  cudaMalloc(&d_clusterNo, N * sizeof(int));
  cudaMemset(d_clusterNo, 0, N * sizeof(int));

  thrust::device_vector<float> d_x = h_x;
  thrust::device_vector<float> d_y = h_y;

  std::mt19937 rng(std::random_device{}());
  std::shuffle(h_x.begin(), h_x.end(), rng);
  std::shuffle(h_y.begin(), h_y.end(), rng);
  thrust::device_vector<float> d_mean_x(h_x.begin(), h_x.begin() + k);
  thrust::device_vector<float> d_mean_y(h_y.begin(), h_y.begin() + k);

  thrust::device_vector<float> d_sums_x(k);
  thrust::device_vector<float> d_sums_y(k);
  thrust::device_vector<int> d_counts(k, 0);

  const int threads = 1024;
  const int blocks = (number_of_elements + threads - 1) / threads;

  for (size_t iteration = 0; iteration < number_of_iterations; ++iteration) {
    thrust::fill(d_sums_x.begin(), d_sums_x.end(), 0);
    thrust::fill(d_sums_y.begin(), d_sums_y.end(), 0);
    thrust::fill(d_counts.begin(), d_counts.end(), 0);

    assign_clusters<<<blocks, threads>>>(d_x.data(),
                                         d_y.data(),
                                         number_of_elements,
                                         d_mean_x.data(),
                                         d_mean_y.data(),
                                         d_sums_x.data(),
                                         d_sums_y.data(),
                                         k,
                                         d_counts.data(),
					 d_clusterNo);
    cudaDeviceSynchronize();

    compute_new_means<<<1, k>>>(d_mean_x.data(),
                                d_mean_y.data(),
                                d_sums_x.data(),
                                d_sums_y.data(),
                                d_counts.data());
    cudaDeviceSynchronize();
  }

  cudaMemcpy(h_clusterNo, d_clusterNo, N * sizeof(int), cudaMemcpyDeviceToHost);

  std::remove("tmp");
  ofstream outputfile("tmp"); 

  for(int i=0; i < N; i++)
  {
	outputfile << h_x[i] << "," << h_y[i] << "," << h_clusterNo[i] << std::endl;
  	// std::cout << h_x[i] << "," << h_y[i] << "," << h_clusterNo[i] << std::endl;
  }

/*
  cudaMemcpy(h_clusterNo, d_clusterNo, N * sizeof(int), cudaMemcpyDeviceToHost);

  for(int i=0; i < N; i++)
  	  std::cout << h_x[i] << "," << h_y[i] << "," << h_clusterNo[i] << std::endl;
*/

}
