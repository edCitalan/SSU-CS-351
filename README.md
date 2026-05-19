# SSU-CS-351

A collection of projects from CS 351 at Sonoma State University.

---

## Project 1
Low-level C/C++ memory and data structure exercises covering stack allocation, heap allocation, linked lists, and more.

## Project 3 — Drawing Shapes with WebGL
This project is about learning how to draw things on a web page using WebGL, which is a way to do graphics programming directly in the browser. Instead of loading images or using a library, everything is drawn from scratch using math.

The project is split into five steps, each one building on the last:

1. **Wireframe Triangle** — Draws a simple triangle made of lines using basic math (sine and cosine) to place the corners evenly around a circle.
2. **10-Sided Polygon** — Fills in a 10-sided shape (like a circle made of wedges) by switching from drawing lines to drawing filled triangles that all share a center point.
3. **Five-Pointed Star** — Turns the polygon into a star by making every other point stick out further and the ones in between stay closer to the center.
4. **Rotating Star** — Makes the star spin by adding a time value to the angle math every frame, so it animates continuously in the browser.
5. **Colorful Rotating Star** *(Extra Credit)* — Adds color to the spinning star. The tips are gold and the inner parts are red, and the color smoothly blends between them.

## Project 4 — NVIDIA CUDA Applications
This project is about writing GPU-accelerated programs using NVIDIA CUDA. Instead of running code on the CPU one step at a time, CUDA lets thousands of threads run in parallel on the GPU at once.

The project has two separate programs:

1. **CUDA iota** — Implements the `std::iota` function (fills an array with sequential values like `[0, 1, 2, 3, ...]`) as a CUDA kernel, where each GPU thread writes exactly one element. Both a CPU and GPU version are included, and their runtimes are compared to understand when parallelism actually helps.
2. **CUDA Julia Set** — Converts a CPU-based fractal image generator to CUDA. Each GPU thread computes one pixel of an 800×800 image by iterating a complex number equation and counting how quickly the value escapes. The result is a PPM image of the Mandelbrot or Julia set.
