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
