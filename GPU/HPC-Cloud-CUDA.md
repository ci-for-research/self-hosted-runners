## Requirements

Cuda currently officially supports only two versions of Ubuntu: 18.04 and 16.04. This instructions were tested on Ubuntu 18.04.

## System info

Distribution info
```
# lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 18.04.4 LTS
Release:        18.04
Codename:       bionic
```

Kernel version

```
# uname -a
Linux packer-Ubuntu-18 4.15.0-101-generic #102-Ubuntu SMP Mon May 11 10:07:26 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

GPU hardware information
```
# lspci | grep -i nvidia
01:01.0 VGA compatible controller: NVIDIA Corporation GK104GL [GRID K2] (rev a1)
```

## Install CUDA Toolkit and Drivers

```
# apt install nvidia-profiler nvidia-headless-440 nvidia-cuda-toolkit nvidia-compute-utils-440 nvidia-cuda-gdb   nvidia-visual-profiler nvidia-cuda-doc g++
```

## Reboot the computer

```
# reboot
```

## Testing

### Cuda compiler
Check the cuda compiler version.

```
# nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2017 NVIDIA Corporation
Built on Fri_Nov__3_21:07:56_CDT_2017
Cuda compilation tools, release 9.1, V9.1.85
```

### Compile and test Hello World example

Save the example code below as `hello_world.cu`.
```cpp
#include<stdio.h>
#include<stdlib.h>

__global__ void print_from_gpu(void) {
    printf("Hello World! from thread [%d,%d] \
        From device\n", threadIdx.x,blockIdx.x);
}

int main(void) {
    printf("Hello World from host!\n");
    print_from_gpu<<<1,1>>>();
    cudaDeviceSynchronize();
    return 0;
}
```

Compile the example:
```
# nvcc -o hello_world.exe hello_world.cu
```

Run the example:
```
# ./hello
Hello World from host!
```
