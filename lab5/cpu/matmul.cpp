#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int N = (1 << 10);

void gemm_baseline(float *A, float *B, float *C); // you can use inline function

int main(void) {
    float *A = (float *)malloc(N * N * sizeof(float));
    float *B = (float *)malloc(N * N * sizeof(float));
    float *C = (float *)malloc(N * N * sizeof(float));

    //随机初始化A，B
    srand(time(NULL));
    for (int i = 0; i < N * N; i++) {
        A[i] = (float)rand() / RAND_MAX;
        B[i] = (float)rand() / RAND_MAX;
    }
    // measure time
    clock_t start = clock();
    gemm_baseline(A, B, C);
    clock_t end = clock();
    printf("Time1: %f s\n", (double)(end - start) / CLOCKS_PER_SEC);

    free(A);
    free(B);
    free(C);
    return 0;
}
void gemm_baseline(float *A, float *B, float *C) {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            for (int k = 0; k < N; k++)
                C[i * N + j] += A[i * N + k] * B[k * N + j];
}
