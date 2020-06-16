## Resources
SURF HPC Documentation
https://doc.hpccloud.surfsara.nl/gpu-attach


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

## Pre install

Cuda 8 only works with only gcc 5.0.
```
# apt install gcc-5 g++-5
```

## Install

Check compatibility first
https://docs.nvidia.com/deploy/cuda-compatibility/index.html

See what drivers you need
https://www.nvidia.com/Download/index.aspx?lang=en-us

### Install Nvidia drivers

```
# wget http://us.download.nvidia.com/XFree86/Linux-x86_64/367.134/NVIDIA-Linux-x86_64-367.134.run
sh ./NVIDIA-Linux-x86_64-367.134.run --accept-license  -s
```


### Install Cuda

Download Cuda installer
```
# wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run
```

Download Patch release
```
# wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/cuda_8.0.61.2_linux-run
```
Install
```
# sh ./cuda_8.0.61_375.26_linux-run --silent --samples --toolkit --override --verbose
```

### Fix Perl issue
See: https://forums.developer.nvidia.com/t/cant-locate-installutils-pm-in-inc/46952/10

```
# sh ./cuda_8.0.61_375.26_linux-run  --tar mxvf
# cp InstallUtils.pm /usr/lib/x86_64-linux-gnu/perl-base/
# export $PERL5LIB
# rm -rf InstallUtils.pm cuda-installer.pl run_files uninstall_cuda.pl
```

### Environment variables

Add the lines below to .profile

```
# export PATH=$PATH:/usr/local/cuda-8.0/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-8.0/lib64
```

## Test

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