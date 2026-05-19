#include <cuda_runtime.h>
#include <fstream>
#include <iostream>
#include <vector>
#include "CudaCheck.h"

const int WIDTH    = 800;
const int HEIGHT   = 800;
const int MAX_ITER = 256;

// Simple complex number usable in both host and device code
struct Complex {
    float r, i;
    __host__ __device__ Complex(float r = 0.0f, float i = 0.0f) : r(r), i(i) {}
    __host__ __device__ Complex operator+(const Complex& o) const { return {r + o.r, i + o.i}; }
    __host__ __device__ Complex operator*(const Complex& o) const {
        return {r * o.r - i * o.i, r * o.i + i * o.r};
    }
    __host__ __device__ float magnitude() const { return sqrtf(r * r + i * i); }
};

// Helper to match the porting pattern described in the assignment
inline __device__ float magnitude(const Complex& z) { return z.magnitude(); }

struct Color { unsigned char r, g, b; };

__device__ Color setColor(int iter) {
    if (iter == MAX_ITER) return {0, 0, 0};
    float t = float(iter) / MAX_ITER;
    return {
        static_cast<unsigned char>(9    * (1-t) * t * t * t         * 255),
        static_cast<unsigned char>(15   * (1-t) * (1-t) * t * t     * 255),
        static_cast<unsigned char>(8.5f * (1-t) * (1-t) * (1-t) * t * 255)
    };
}

// One thread per pixel: iterate z = z^2 + c and count escapes
__global__ void juliaKernel(Color* image, int width, int height,
                             Complex ll, Complex ur,
                             Complex julia_c, bool mandelbrot) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (col >= width || row >= height) return;

    float x = ll.r + (ur.r - ll.r) * float(col) / width;
    float y = ll.i + (ur.i - ll.i) * float(row) / height;
    Complex pixel(x, y);

    Complex z = mandelbrot ? Complex(0.0f, 0.0f) : pixel;
    Complex c = mandelbrot ? pixel                : julia_c;

    int iter = 0;
    while (iter < MAX_ITER && magnitude(z) < 2.0f) {
        z = z * z + c;
        ++iter;
    }

    image[row * width + col] = setColor(iter);
}

int main(int argc, char* argv[]) {
    float cr = 0.0f, ci = 0.0f;
    if (argc >= 3) { cr = std::stof(argv[1]); ci = std::stof(argv[2]); }
    bool mandelbrot = (cr == 0.0f && ci == 0.0f);

    Complex ll(-2.0f, -2.0f);
    Complex ur( 2.0f,  2.0f);
    Complex julia_c(cr, ci);

    Color* d_image = nullptr;
    CUDA_CHECK(cudaMalloc(&d_image, WIDTH * HEIGHT * sizeof(Color)));

    dim3 block(16, 16);
    dim3 grid((WIDTH  + block.x - 1) / block.x,
              (HEIGHT + block.y - 1) / block.y);

    juliaKernel<<<grid, block>>>(d_image, WIDTH, HEIGHT, ll, ur, julia_c, mandelbrot);
    CUDA_CHECK(cudaDeviceSynchronize());

    std::vector<Color> h_image(WIDTH * HEIGHT);
    CUDA_CHECK(cudaMemcpy(h_image.data(), d_image, WIDTH * HEIGHT * sizeof(Color),
                          cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaFree(d_image));

    std::ofstream out("julia.ppm", std::ios::binary);
    out << "P6\n" << WIDTH << " " << HEIGHT << "\n255\n";
    for (auto& c : h_image)
        out.write(reinterpret_cast<const char*>(&c), 3);

    std::cout << "Generated julia.ppm (" << WIDTH << "x" << HEIGHT << ")\n";
    return 0;
}
