#include <stdio.h>
#include <stdlib.h>
#include <immintrin.h>
#include <time.h>

int N = (1 << 8);

void gemm_verify(float *A, float *B, float *C); // you can use inline function
void gemm_avx(float *A, float *B, float *C); // you can use inline function

int main(void) {
    // malloc A, B, C
    float *A = (float *)malloc(N * N * sizeof(float));
    float *B = (float *)malloc(N * N * sizeof(float));
    float *C = (float *)malloc(N * N * sizeof(float));

    // random initialize A, B
    srand(time(NULL));
    for (int i = 0; i < N * N; i++) {
        A[i] = (float)rand() / RAND_MAX;
        B[i] = (float)rand() / RAND_MAX;
    }

    // measure time
    clock_t start = clock();
    gemm_avx(A, B, C);
    clock_t end = clock();
    printf("Time2: %f s\n", (double)(end - start) / CLOCKS_PER_SEC);

    // use gemm_baseline verify gemm_avx
    gemm_verify(A, B, C);

    free(A);
    free(B);
    free(C);

    return 0;
}

void gemm_verify(float *A, float *B, float *C) {
    float tmp;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            tmp = 0;
            for (int k = 0; k < N; k++)
                tmp += A[i * N + k] * B[k * N + j];
            if (C[i * N + j] - tmp > 1e-4 || C[i * N + j] - tmp < -1e-4) {
                printf("Error!\n");
            }
        }
}

void gemm_avx(float *A, float *B, float *C) {
    __m256 a, b, c;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j+=8) {
            c = _mm256_setzero_ps();
            for (int k = 0; k < N; k++) {//一次计算8列
                a = _mm256_set1_ps(A[i * N + k]);
                b = _mm256_loadu_ps(&B[k * N + j]);
                c = _mm256_fmadd_ps(a, b, c);
            }
            _mm256_storeu_ps(&C[i * N + j], c);
        }
}
