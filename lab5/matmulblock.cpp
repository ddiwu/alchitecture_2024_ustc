#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <immintrin.h>

int BLOCK_SIZE = (1 << 4);//小一些相对好一些
int N = (1 << 8);

void gemm_verify(float *A, float *B, float *C); // you can use inline function

// you may need to add some additional function parameters to adjust the blocking  strategy.
void gemm_avx_block(float *A, float *B, float *C); // you can use inline function

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
        C[i] = 0;//计算的C会先load，所以初始化很重要
    }
    // measure time
    clock_t start = clock();
    gemm_avx_block(A, B, C);
    clock_t end = clock();
    printf("Time3: %f s\n", (double)(end - start) / CLOCKS_PER_SEC);

    // use gemm_baseline verify gemm_avx
    gemm_verify(A, B, C);

    free(A);
    free(B);
    free(C);

    return 0;
}

// void gemm_verify(float *A, float *B, float *C) {
//     float tmp;
//     for (int i = 0; i < N; i++)
//         for (int j = 0; j < N; j++) {
//             tmp = 0;
//             for (int k = 0; k < N; k++)
//                 tmp += A[i * N + k] * B[k * N + j];
//             if (C[i * N + j] - tmp > 1e-1 || C[i * N + j] - tmp < -1e-1) {
//                 printf("Error!\n");
//             }
//         }
// }
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
        if (C[i] - baseline[i]>1e-2|| C[i] - baseline[i]<-1e-2)
        {
            printf("fail: C[%d] = %f, baseline[%d] = %f\n", i, C[i], i, baseline[i]);
            break;
        }
    }
    free(baseline);
}

void gemm_avx_block(float *A, float *B, float *C) {
    __m256 a, b, c;
    for (int bi = 0; bi < N; bi+=BLOCK_SIZE)
        for (int bj = 0; bj < N; bj+=BLOCK_SIZE)
            for (int bk = 0; bk < N; bk+=BLOCK_SIZE)
                for (int i = bi; i < bi + BLOCK_SIZE; i++)
                    for (int j = bj; j < bj + BLOCK_SIZE; j+=8) {
                        c = _mm256_loadu_ps(&C[i * N + j]);
                        for (int k = bk; k < bk + BLOCK_SIZE; k++) {
                            a = _mm256_set1_ps(A[i * N + k]);
                            b = _mm256_loadu_ps(&B[k * N + j]);
                            c = _mm256_fmadd_ps(a, b, c);
                        }
                        // __m256 t = _mm256_loadu_ps(&C[i * N + j]);
                        // c = _mm256_add_ps(c, t);
                        _mm256_storeu_ps(&C[i * N + j], c);
                    }
}
