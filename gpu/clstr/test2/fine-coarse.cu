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

#include "timer.h"

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
__global__ void assign_clusters(const float* __restrict__ data_x,
                                const float* __restrict__ data_y,
                                int data_size,
                                const float* __restrict__ means_x,
                                const float* __restrict__ means_y,
                                float* __restrict__ new_sums_x,
                                float* __restrict__ new_sums_y,
                                int k,
                                int* __restrict__ counts,
				int* clusterNo) {
  const int index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index >= data_size) return;

  // printf("data_size %d \n", data_size);

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
      // printf("best_cluster %d \n", cluster);
      clusterNo[index] = cluster;
    }
  }

  // Slow but simple.
  atomicAdd(&new_sums_x[best_cluster], x);
  atomicAdd(&new_sums_y[best_cluster], y);
  atomicAdd(&counts[best_cluster], 1);
}

// Each thread is one cluster, which just recomputes its coordinates as the mean
// of all points assigned to it.
__global__ void compute_new_means(float* __restrict__ means_x,
                                  float* __restrict__ means_y,
                                  const float* __restrict__ new_sum_x,
                                  const float* __restrict__ new_sum_y,
                                  const int* __restrict__ counts) {
  const int cluster = threadIdx.x;
  // Threshold count to turn 0/0 into 0/1.
  const int count = max(1, counts[cluster]);
  means_x[cluster] = new_sum_x[cluster] / count;
  means_y[cluster] = new_sum_y[cluster] / count;
}



__global__ void fine_reduce(const float* __restrict__ data_x,
                            const float* __restrict__ data_y,
                            int data_size,
                            const float* __restrict__ means_x,
                            const float* __restrict__ means_y,
                            float* __restrict__ new_sums_x,
                            float* __restrict__ new_sums_y,
                            int k,
                            int* __restrict__ counts,
			    int* clusterNo) {
  // Essentially three dimensional: n * x, n * y, n * counts.
  extern __shared__ float shared_data[];

  const int local_index = threadIdx.x;
  const int global_index = blockIdx.x * blockDim.x + threadIdx.x;
  if (global_index >= data_size) return;

  // Load the mean values into shared memory.
  if (local_index < k) {
    shared_data[local_index] = means_x[local_index];
    shared_data[k + local_index] = means_y[local_index];
  }

  __syncthreads();

  // Assignment step.

  // Load once here.
  const float x_value = data_x[global_index];
  const float y_value = data_y[global_index];

  float best_distance = FLT_MAX;
  int best_cluster = -1;
  for (int cluster = 0; cluster < k; ++cluster) {
    const float distance = squared_l2_distance(x_value,
                                               y_value,
                                               shared_data[cluster],
                                               shared_data[k + cluster]);
    if (distance < best_distance) {
      best_distance = distance;
      best_cluster = cluster;
      clusterNo[global_index] = cluster;
    }
  }

  __syncthreads();

  // Reduction step.

  const int x = local_index;
  const int y = local_index + blockDim.x;
  const int count = local_index + blockDim.x + blockDim.x;

  for (int cluster = 0; cluster < k; ++cluster) {
    // Zeros if this point (thread) is not assigned to the cluster, else the
    // values of the point.
    shared_data[x] = (best_cluster == cluster) ? x_value : 0;
    shared_data[y] = (best_cluster == cluster) ? y_value : 0;
    shared_data[count] = (best_cluster == cluster) ? 1 : 0;
    __syncthreads();

    // Tree-reduction for this cluster.
    for (int stride = blockDim.x / 2; stride > 0; stride /= 2) {
      if (local_index < stride) {
        shared_data[x] += shared_data[x + stride];
        shared_data[y] += shared_data[y + stride];
        shared_data[count] += shared_data[count + stride];
      }
      __syncthreads();
    }

    // Now shared_data[0] holds the sum for x.

    if (local_index == 0) {
      const int cluster_index = blockIdx.x * k + cluster;
      new_sums_x[cluster_index] = shared_data[x];
      new_sums_y[cluster_index] = shared_data[y];
      counts[cluster_index] = shared_data[count];
    }
    __syncthreads();
  }
}

__global__ void coarse_reduce(float* __restrict__ means_x,
                              float* __restrict__ means_y,
                              float* __restrict__ new_sum_x,
                              float* __restrict__ new_sum_y,
                              int k,
                              int* __restrict__ counts) {
  extern __shared__ float shared_data[];

  const int index = threadIdx.x;
  const int y_offset = blockDim.x;

  // Load into shared memory for more efficient reduction.
  shared_data[index] = new_sum_x[index];
  shared_data[y_offset + index] = new_sum_y[index];
  __syncthreads();

  for (int stride = blockDim.x / 2; stride >= k; stride /= 2) {
    if (index < stride) {
      shared_data[index] += shared_data[index + stride];
      shared_data[y_offset + index] += shared_data[y_offset + index + stride];
    }
    __syncthreads();
  }

  // The first k threads can recompute their clusters' means now.
  if (index < k) {
    const int count = max(1, counts[index]);
    means_x[index] = new_sum_x[index] / count;
    means_y[index] = new_sum_y[index] / count;
    new_sum_y[index] = 0;
    new_sum_x[index] = 0;
    counts[index] = 0;
  }
}
int main(int argc, const char* argv[]) {
  std::vector<float> h_x;
  std::vector<float> h_y;

  unsigned int t, travdirtime;

  // Load x and y into host vectors ... (omitted)

  int N = atoi(argv[2]);
  int k = atoi(argv[4]);
  int number_of_iterations = atoi(argv[3]);

  const string csv_file = std::string(argv[1]); 
  vector<vector<string>> data2; 

  Csv objCsv(csv_file);
  if (!objCsv.getCsv(data2)) {
     cout << "read ERROR" << endl;
     return 1;
  }

  // for (int row = 0; row < data2.size(); row++) {
  for (int row = 0; row < 1024; row++) {
      vector<string> rec = data2[row]; 
      h_x.push_back(std::stof(rec[0]));
      h_y.push_back(std::stof(rec[1]));
  }

  start_timer(&t); 

  const size_t number_of_elements = h_x.size();
  Data d_data(number_of_elements, h_x, h_y);

  // Random shuffle the data and pick the first
  // k points (i.e. k random points).
  std::random_device seed;
  std::mt19937 rng(seed());
  std::shuffle(h_x.begin(), h_x.end(), rng);
  std::shuffle(h_y.begin(), h_y.end(), rng);
  Data d_means(k, h_x, h_y);
  Data d_sums(k);

  int* d_counts;
  cudaMalloc(&d_counts, k * sizeof(int));
  cudaMemset(d_counts, 0, k * sizeof(int));

  int* h_counts;
  h_counts = (int *)malloc(k * sizeof(int));

  int* h_clusterNo;
  h_clusterNo = (int *)malloc(N * sizeof(int)); 

  int* d_clusterNo;
  cudaMalloc(&d_clusterNo, N * sizeof(int));
  cudaMemset(d_clusterNo, 0, N * sizeof(int));

  const int threads = N;
  const int blocks = (number_of_elements + threads - 1) / threads;

  const int fine_shared_memory = 3 * threads * sizeof(float);
// * 2 for x and y. Will have k * blocks threads for the coarse reduction.
const int coarse_shared_memory = 2 * k * blocks * sizeof(float);
// ...
for (size_t iteration = 0; iteration < number_of_iterations; ++iteration) {
  fine_reduce<<<blocks, threads, fine_shared_memory>>>(d_data.x,
                                                       d_data.y,
                                                       d_data.size,
                                                       d_means.x,
                                                       d_means.y,
                                                       d_sums.x,
                                                       d_sums.y,
                                                       k,
                                                       d_counts,
						       d_clusterNo);
  cudaDeviceSynchronize();

  coarse_reduce<<<1, k * blocks, coarse_shared_memory>>>(d_means.x,
                                                         d_means.y,
                                                         d_sums.x,
                                                         d_sums.y,
                                                         k,
                                                         d_counts);

  cudaDeviceSynchronize();
}

  cudaMemcpy(h_clusterNo, d_clusterNo, N * sizeof(int), cudaMemcpyDeviceToHost);

  travdirtime = stop_timer(&t);
  print_timer(travdirtime); 


/*
  for(int i=0; i < N; i++)
  	  std::cout << h_x[i] << "," << h_y[i] << "," << h_clusterNo[i] << std::endl;
*/

/*

  for (size_t iteration = 0; iteration < number_of_iterations; ++iteration) {
    cudaMemset(d_counts, 0, k * sizeof(int));
    d_sums.clear();

    assign_clusters<<<blocks, threads>>>(d_data.x,
                                         d_data.y,
                                         d_data.size,
                                         d_means.x,
                                         d_means.y,
                                         d_sums.x,
                                         d_sums.y,
                                         k,
                                         d_counts,
					 d_clusterNo);
    cudaDeviceSynchronize();

    compute_new_means<<<1, k>>>(d_means.x,
                                d_means.y,
                                d_sums.x,
                                d_sums.y,
                                d_counts);
    cudaDeviceSynchronize();
  }

  cudaMemcpy(h_clusterNo, d_clusterNo, N * sizeof(int), cudaMemcpyDeviceToHost);

  for(int i=0; i < N; i++)
  	  std::cout << h_x[i] << "," << h_y[i] << "," << h_clusterNo[i] << std::endl;
*/

}
