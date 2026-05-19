#include <cuda_runtime.h>
#include <chrono>
#include <iostream>
#include <vector>
#include "CudaCheck.h"

using DataType = float;

// Each thread writes one element: values[i] = i + startValue
__global__ void iotaKernel(size_t n, DataType* values, DataType startValue) {
    size_t i = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    if (i < n) {
        values[i] = static_cast<DataType>(i) + startValue;
    }
}

int main(int argc, char* argv[]) {
    size_t n = 1 << 24; // 16M elements
    if (argc > 1) n = std::stoul(argv[1]);

    DataType* d_values = nullptr;
    CUDA_CHECK(cudaMalloc(&d_values, n * sizeof(DataType)));

    const int blockSize = 256;
    const int gridSize  = static_cast<int>((n + blockSize - 1) / blockSize);

    auto start = std::chrono::high_resolution_clock::now();
    iotaKernel<<<gridSize, blockSize>>>(n, d_values, DataType(0));
    CUDA_CHECK(cudaDeviceSynchronize());
    auto end = std::chrono::high_resolution_clock::now();

    std::vector<DataType> h_values(n);
    CUDA_CHECK(cudaMemcpy(h_values.data(), d_values, n * sizeof(DataType), cudaMemcpyDeviceToHost));

    bool correct = true;
    for (size_t i = 0; i < n; ++i) {
        if (h_values[i] != static_cast<DataType>(i)) {
            std::cerr << "Verification failed at index " << i << std::endl;
            correct = false;
            break;
        }
    }

    CUDA_CHECK(cudaFree(d_values));

    if (!correct) return 1;

    std::chrono::duration<double, std::milli> elapsed = end - start;
    std::cout << elapsed.count() << std::endl;
    return 0;
}
