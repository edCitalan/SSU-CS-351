NVCC     = nvcc
CXX      = g++
CXXFLAGS = -O2 -std=c++17
NVCCFLAGS = -O2 -std=c++17

.PHONY: all clean

all: iota.cpu iota.gpu julia.cpu julia.gpu

iota.cpu: iota.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

iota.gpu: iota.cu CudaCheck.h
	$(NVCC) $(NVCCFLAGS) -o $@ iota.cu

julia.cpu: julia.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

julia.gpu: julia.cu CudaCheck.h
	$(NVCC) $(NVCCFLAGS) -o $@ julia.cu

clean:
	rm -f iota.cpu iota.gpu julia.cpu julia.gpu *.ppm
