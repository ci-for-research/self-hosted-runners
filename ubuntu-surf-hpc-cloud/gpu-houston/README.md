## Intro

This short guide shows how to install Nvidia drivers and CUDA for GRID K2 hardware. For more information about GPUs on SURF HPC Cloud please visit [SURF HPC Documentation](https://doc.hpccloud.surfsara.nl/gpu-attach).

We have 2 methods to install Nvidia drivers and Cuda.
- Using ansible playbook
- Following the steps and installing manually

## 1- Installation using ansible playbook

The command below runs the ansible-playbook and installs all necassary software. This ansible-playbook is specifically written for SURF HPC Cloud platform and GRID K2 hardware. However, it can easily be adapted for different platforms and graphics cards.

```shell
ANSIBLE_HOST_KEY_CHECKING=False  docker run --rm -ti -v $PWD:/nlesc -v $YOUR_PRIVATE_KEY:/nlesc/id_rsa_ci_sprint  ansible/ansible-runner  ansible-playbook --become-user=ubuntu --inventory-file /nlesc/GPU/hosts /nlesc/GPU/install_cuda_grid2k.yml --private-key=/nlesc/id_rsa_ci_sprint --verbose
```

You will need to change ``$YOUR_PRIVATE_KEY`` with full path of your private key and ``hosts`` file which has to connection details of the server.

## 2- Manual installation

## Requirements

Cuda currently officially supports only two versions of Ubuntu: 18.04 and 16.04. This instructions were tested on Ubuntu 18.04.

## System info

Distribution info

```shell
lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 18.04.4 LTS
Release:        18.04
Codename:       bionic
```

Kernel version

```shell
uname -a
Linux packer-Ubuntu-18 4.15.0-101-generic #102-Ubuntu SMP Mon May 11 10:07:26 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

GPU hardware information

```shell
lspci | grep -i nvidia
01:01.0 VGA compatible controller: NVIDIA Corporation GK104GL [GRID K2] (rev a1)
```

## Pre install

For Grid K2 card we will need Cuda 8.0. Cuda 8.0 only works with only gcc 5.0 so it should be installed before.

To decide what version of cuda and Nvidia drivers you need, please check the links below.

See what drivers you need:
https://www.nvidia.com/Download/index.aspx?lang=en-us

Check compatibility first:
https://docs.nvidia.com/deploy/cuda-compatibility/index.html

```shell
apt install gcc-5 g++-5
```

## Install

### Install Nvidia drivers

Download Nvidia driver (version 367) and install it.

```shell
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/367.134/NVIDIA-Linux-x86_64-367.134.run
sh ./NVIDIA-Linux-x86_64-367.134.run --accept-license  -s
```

### Install Cuda

Download Cuda 8.0 installer
```
# wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run
```

Download Patch release:

```shell
wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/cuda_8.0.61.2_linux-run
```

### Fix Perl issue

While installing Cuda, we had some issues related to Perl scripts.
See: https://forums.developer.nvidia.com/t/cant-locate-installutils-pm-in-inc/46952/10


These commands solves the Perl issues.

```shell
sh ./cuda_8.0.61_375.26_linux-run  --tar mxvf
cp InstallUtils.pm /usr/lib/x86_64-linux-gnu/perl-base/
export $PERL5LIB
rm -rf InstallUtils.pm cuda-installer.pl run_files uninstall_cuda.pl
```

### Install Cuda

After fixing the Perl issue, we can install Cuda.

```shell
sh ./cuda_8.0.61_375.26_linux-run --silent --samples --toolkit --override --verbose
```

### Environment variables

In order to be able to use Cuda, we need to change our environment variables.

Add the lines below to .profile file.

```shell
export PATH=$PATH:/usr/local/cuda-8.0/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-8.0/lib64
```

## Test the installation

### Cuda compiler

Check the cuda compiler version.

```shell
nvcc --version
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

__global__ void print_gpu(void) {
    printf("Houston, we have a problem in section [%d,%d] \
        From Apollo 13\n", threadIdx.x,blockIdx.x);
}

int main(void) {
    printf("This is Houston. Say again, please. \
                From Base\n");
    print_gpu<<<2,2>>>();
    cudaDeviceSynchronize();
    return 0;
}
```

Compile the example:

```shell
nvcc -o hello_world.exe hello_world.cu
```

Run the example:

```shell
./hello
This is Houston. Say again, please.                 From Base
Houston, we have a problem in section [0,0]         From Apollo 13
Houston, we have a problem in section [1,0]         From Apollo 13
Houston, we have a problem in section [0,1]         From Apollo 13
Houston, we have a problem in section [1,1]         From Apollo 13
```
