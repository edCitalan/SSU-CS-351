#include <chrono>
#include <iostream>
#include <numeric>
#include <vector>

using DataType = float;

int main(int argc, char* argv[]) {
    size_t n = 1 << 24; // 16M elements
    if (argc > 1) n = std::stoul(argv[1]);

    std::vector<DataType> values(n);

    auto start = std::chrono::high_resolution_clock::now();
    std::iota(values.begin(), values.end(), DataType(0));
    auto end = std::chrono::high_resolution_clock::now();

    bool correct = true;
    for (size_t i = 0; i < n; ++i) {
        if (values[i] != static_cast<DataType>(i)) {
            std::cerr << "Verification failed at index " << i << std::endl;
            correct = false;
            break;
        }
    }

    if (!correct) return 1;

    std::chrono::duration<double, std::milli> elapsed = end - start;
    std::cout << elapsed.count() << std::endl;
    return 0;
}
