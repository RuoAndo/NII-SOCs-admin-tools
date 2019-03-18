#include "../common/common.h"
#include <stdio.h>
#include <assert.h>
#include <cuda_runtime.h>

int main(int argc, char **argv)
{
    int ngpus;

    printf("> starting %s", argv[0]);

    CHECK(cudaGetDeviceCount(&ngpus));
    printf(" CUDA-capable devices: %i\n", ngpus);

    return EXIT_SUCCESS;
}
