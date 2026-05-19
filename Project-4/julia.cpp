#include <complex>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>

using Complex = std::complex<float>;

const int   WIDTH    = 800;
const int   HEIGHT   = 800;
const int   MAX_ITER = 256;

// Window into the complex plane
const Complex ll(-2.0f, -2.0f); // lower-left
const Complex ur( 2.0f,  2.0f); // upper-right

inline float magnitude(const Complex& z) { return std::abs(z); }

// Returns iteration count before escape (or MAX_ITER if inside the set)
int julia(Complex z, const Complex& c) {
    int iter = 0;
    while (iter < MAX_ITER && magnitude(z) < 2.0f) {
        z = z * z + c;
        ++iter;
    }
    return iter;
}

struct Color { unsigned char r, g, b; };

Color setColor(int iter) {
    if (iter == MAX_ITER) return {0, 0, 0};
    float t = float(iter) / MAX_ITER;
    return {
        static_cast<unsigned char>(9   * (1-t) * t * t * t         * 255),
        static_cast<unsigned char>(15  * (1-t) * (1-t) * t * t     * 255),
        static_cast<unsigned char>(8.5f* (1-t) * (1-t) * (1-t) * t * 255)
    };
}

int main(int argc, char* argv[]) {
    // julia_c = (0,0) => Mandelbrot (z0=0, c=pixel)
    // julia_c = anything else => Julia set (z0=pixel, c=julia_c)
    float cr = 0.0f, ci = 0.0f;
    if (argc >= 3) { cr = std::stof(argv[1]); ci = std::stof(argv[2]); }
    Complex julia_c(cr, ci);
    bool mandelbrot = (cr == 0.0f && ci == 0.0f);

    std::vector<Color> image(WIDTH * HEIGHT);

    for (int row = 0; row < HEIGHT; ++row) {
        for (int col = 0; col < WIDTH; ++col) {
            float x = ll.real() + (ur.real() - ll.real()) * float(col) / WIDTH;
            float y = ll.imag() + (ur.imag() - ll.imag()) * float(row) / HEIGHT;
            Complex pixel(x, y);

            int iter = mandelbrot ? julia(Complex(0.0f), pixel)
                                  : julia(pixel, julia_c);

            image[row * WIDTH + col] = setColor(iter);
        }
    }

    std::ofstream out("julia.ppm", std::ios::binary);
    out << "P6\n" << WIDTH << " " << HEIGHT << "\n255\n";
    for (auto& c : image)
        out.write(reinterpret_cast<const char*>(&c), 3);

    std::cout << "Generated julia.ppm (" << WIDTH << "x" << HEIGHT << ")\n";
    return 0;
}
