# Project 4 — NVIDIA CUDA Applications

Two standalone CUDA programs: a parallel `iota` implementation and a GPU-accelerated Julia/Mandelbrot set renderer.

---

## Files

| File | Description |
|---|---|
| `iota.cpp` | CPU version using `std::iota` — baseline for timing |
| `iota.cu` | CUDA version — each GPU thread writes one array element |
| `julia.cpp` | CPU Julia/Mandelbrot set renderer, outputs a `.ppm` image |
| `julia.cu` | CUDA version — each GPU thread computes one pixel |
| `Makefile` | Builds `iota.cpu`, `iota.gpu`, `julia.cpu`, `julia.gpu` |
| `runTrials.sh` | Runs a program 5 times and averages the reported runtimes |
| `CudaCheck.h` | Macro to check CUDA API call return codes |

---

## Building

```bash
make
```

---

## Program 1 — CUDA iota

### What it does

`iota` fills an array with sequential values starting from a given number — `[start, start+1, start+2, …]`. The CPU version calls `std::iota`; the CUDA version launches a kernel where each thread handles exactly one element:

```cuda
__global__ void iotaKernel(size_t n, DataType* values, DataType startValue) {
    size_t i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n)
        values[i] = static_cast<DataType>(i) + startValue;
}
```

### Running the timing trials

```bash
./runTrials.sh ./iota.cpu
./runTrials.sh ./iota.gpu
```

### Results

| Implementation | Average time (ms) |
|---|---|
| CPU (`std::iota`) | *(fill in after running)* |
| CUDA kernel | *(fill in after running)* |

### Question: Are the results what you expected? Why isn't CUDA a great fit here?

Not really — the CUDA version is often **slower** than the CPU version for this workload. Here's why:

`iota` is a pure **memory-bandwidth-bound** operation. Each thread does essentially zero arithmetic — it just writes one value to global memory. For CUDA to win, there needs to be enough computation per byte moved (high arithmetic intensity) to hide the overhead of:

1. **Kernel launch latency** — every GPU launch has fixed startup cost.
2. **`cudaMalloc` / `cudaMemcpy` overhead** — allocating device memory and copying results back to the host adds significant wall-clock time that the simple benchmark captures.
3. **Memory bus contention** — thousands of threads all hammering global memory simultaneously can saturate the GPU's memory bus without the computation core doing anything useful.

In short, GPUs are optimized for workloads where each thread performs a lot of math on a little data. `iota` is the opposite: no math, lots of data writes. The CPU's `std::iota` runs in a tight, cache-friendly loop that the hardware prefetcher handles very well, making it hard to beat.

---

## Program 2 — CUDA Julia Set

### What it does

For each pixel in an 800×800 image, the kernel maps the pixel to a point in the complex plane and iterates:

$$z_{n+1} = z_n^2 + c$$

counting how many iterations it takes before $|z| > 2$ (the escape condition). The iteration count drives the color. Points that never escape are inside the set and colored black.

- When `c = (0, 0)`: the program renders the **Mandelbrot set** (starting `z = 0`, varying `c` per pixel).
- With any other constant `c`: a **Julia set** (starting `z` = pixel coordinate, fixed `c`).

### Running

```bash
# Mandelbrot (default)
./julia.gpu

# Julia set with c = -0.7 + 0.27i
./julia.gpu -0.7 0.27
```

Output is written to `julia.ppm`.

### Generated Image

*(Add your rendered image here after running on Oblivus — convert `.ppm` to `.png` with `convert julia.ppm julia.png` then commit it)*

```
![Mandelbrot set rendered with CUDA](julia.png)
```

### Why CUDA excels here (vs. iota)

Each pixel is **independent** and requires up to 256 iterations of complex arithmetic — this is exactly the high arithmetic intensity workload GPUs are designed for. The 800×800 = 640,000 pixels map naturally onto thousands of GPU threads running in parallel, with no communication between them.
