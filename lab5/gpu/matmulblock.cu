#include <stdio.h>
#include <iostream>
#include <chrono>
#define N (1 << 10)
#define BLOCK_SIZE 16
#include <stdlib.h>


__global__ void gemm_block(float *A, float *B, float *C);
void gemm_verify(float *A, float *B, float *C);

int main()
{
	// malloc A, B, C
	float *A = (float*)malloc(N * N * sizeof(float));
	float *B = (float*)malloc(N * N * sizeof(float));
	float *C = (float*)malloc(N * N * sizeof(float));

	// random initialize A, B
	for (int i = 0; i < N * N; i++) {
		A[i] = (float)rand() / RAND_MAX;
		B[i] = (float)rand() / RAND_MAX;
		C[i] = 0;
	}

	// cumalloc A, B, C
	float *cuda_A, *cuda_B, *cuda_C;
	cudaMalloc(&cuda_A, N * N * sizeof(float));
	cudaMalloc(&cuda_B, N * N * sizeof(float));
	cudaMalloc(&cuda_C, N * N * sizeof(float));

	cudaMemcpy(cuda_A, A, N * N * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(cuda_B, B, N * N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_C, C, N * N * sizeof(float), cudaMemcpyHostToDevice);

	// define gridsize and blocksize
	dim3 blocksize(BLOCK_SIZE, BLOCK_SIZE);
	dim3 gridsize((N + blocksize.x - 1) / blocksize.x, (N + blocksize.y - 1) / blocksize.y);

	// compute
	auto start = std::chrono::high_resolution_clock::now();
	gemm_block<<<gridsize, blocksize>>>(cuda_A, cuda_B, cuda_C);
	auto end = std::chrono::high_resolution_clock::now();
	cudaDeviceSynchronize();

	std::chrono::duration<double> diff = end - start;
	printf("Time2: %f s\n", diff.count());

	cudaMemcpy(C, cuda_C, N * N * sizeof(float), cudaMemcpyDeviceToHost);

	// gemm_verify(A, B, C);
	gemm_verify(A, B, C);

	// free mem
	cudaFree(cuda_A);
	cudaFree(cuda_B);
	cudaFree(cuda_C);
	free(A);
	free(B);
	free(C);

	return 0;
}

__global__ void gemm_block(float* A, float * B, float* C) {
    __shared__ float As[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ float Bs[BLOCK_SIZE][BLOCK_SIZE];

	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
    int srow = threadIdx.y;
    int scol = threadIdx.x;

    for (int b = 0; b < N/BLOCK_SIZE; b++) {
        As[srow][scol] = A[row * N + b * BLOCK_SIZE + scol];
        Bs[srow][scol] = B[(b * BLOCK_SIZE + srow) * N + col];
        __syncthreads();
        for (int i = 0; i < BLOCK_SIZE; i++) {
            C[row * N + col] += As[srow][i] * Bs[i][scol];
        }
        __syncthreads();
    }
}

void gemm_verify(float *A, float *B, float *C)
{
    float *baseline = (float *)malloc(N * N * sizeof(float));
    for (int i = 0; i < N * N; i++)
        baseline[i] = 0;
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            for (int k = 0; k < N; k++)
            {
                baseline[i * N + j] += A[i * N + k] * B[k * N + j];
            }
        }
    }

    for (int i = 0; i < N * N; i++)
    {
        if (C[i] - baseline[i]>1e-3|| C[i] - baseline[i]<-1e-3)
        {
            printf("fail: C[%d] = %f, baseline[%d] = %f\n", i, C[i], i, baseline[i]);
            break;
        }
    }
    free(baseline);
}
