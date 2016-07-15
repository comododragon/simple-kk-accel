/* ********************************************************************************************* */
/* * KK-Algorithm for Strongly Non-Singular Matrices Inversion (Accelerated NIOS Version)      * */
/* * Authors: André Bannwart Perina, Luciano Falqueto                                          * */
/* * Based on algorithm developed by Rajani M. Kant and Takayuki Kimura                        * */
/* * Available at: http://dl.acm.org/citation.cfm?id=803034                                    * */
/* ********************************************************************************************* */
/* * Copyright (c) 2016 André B. Perina                                                        * */
/* *                    Luciano Falqueto                                                       * */
/* *                                                                                           * */
/* * Permission is hereby granted, free of charge, to any person obtaining a copy of this      * */
/* * software and associated documentation files (the "Software"), to deal in the Software     * */
/* * without restriction, including without limitation the rights to use, copy, modify,        * */
/* * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to        * */
/* * permit persons to whom the Software is furnished to do so, subject to the following       * */
/* * conditions:                                                                               * */
/* *                                                                                           * */
/* * The above copyright notice and this permission notice shall be included in all copies     * */
/* * or substantial portions of the Software.                                                  * */
/* *                                                                                           * */
/* * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,       * */
/* * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR  * */
/* * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE * */
/* * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR      * */
/* * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER    * */
/* * DEALINGS IN THE SOFTWARE.                                                                 * */
/* ********************************************************************************************* */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "altera_avalon_performance_counter.h"
#include "io.h"
#include "sys/alt_timestamp.h"
#include "system.h"

/**
 * @brief Exact size of matrix.
 */
#define N 4

/**
 * @brief Fractional multiplier (multiplying an integer value by this will make it fixedpoint with 16-bit fractional size).
 */
#define FRAC 65536

/**
 * @brief Fixedpoint fractional bits.
 */
#define FRAC_BIT 16

/**
 * @brief Fixedpoint integer bits.
 */
#define INT_BIT 16

/**
 * @brief Uncomment this define to enable timestamp profiling.
 */
//#define ACTIVATE_TIMESTAMP

/**
 * @brief Uncomment this define to enable profiling via Altera Performance Counter.
 */
#define ACTIVATE_PERFCOUNT

/**
 * @brief Transform a fixedpoint element to float.
 *
 * @param elem Fixedpoint element.
 *
 * @return Float element.
 */
float to_float(int elem) {
	return elem / (float) FRAC;
}

/**
 * @brief Transform a float to fixedpoint element.
 *
 * @param elem Float element.
 *
 * @return Fixedpoint element.
 */
int to_bit(float elem) {
	int e = elem * FRAC;
	return ((e & 0x80000000) >> (32 - (FRAC_BIT + INT_BIT))) | e;
}

/**
 * @brief Put a matrix element.
 *
 * @param elem Float element.
 * @param i Line index.
 * @param j Column index.
 */
void kk_putelem(float elem, int i, int j) {
	IOWR_32DIRECT(KK_ACCEL_BASE, (((i << 8) & 0xff00) | (j & 0xff)) << 2, to_bit(elem));
}

/**
 * @brief Start iterations.
 */
void kk_start(void) {
	IOWR_32DIRECT(KK_ACCEL_BASE, 0x10000 << 2, 0);
}

/**
 * @brief Check if system is still running.
 *
 * @return 1 if system is still running, 0 otherwise.
 */
char kk_isrunning(void) {
	return IORD_32DIRECT(KK_ACCEL_BASE, 0x10001 << 2);
}

/**
 * @brief Return cycles counter.
 *
 * @return Cycles counter.
 */
unsigned int kk_getcounter(void) {
	return IORD_32DIRECT(KK_ACCEL_BASE, 0x10002 << 2);
}

/**
 * @brief Return division by zero flag.
 *
 * @return 1 if any division by zero occurred, 0 otherwise.
 */
char kk_divzero(void) {
	return IORD_32DIRECT(KK_ACCEL_BASE, 0x10003 << 2);
}

/**
 * @brief Get intermediate matrix element.
 *
 * @param i Line index.
 * @param j Column index.
 *
 * @return Intermediate matrix element as float.
 */
float kk_getintelem(int i, int j) {
	return to_float(IORD_32DIRECT(KK_ACCEL_BASE, (0x20000 | ((i << 8) & 0xff00) | (j & 0xff)) << 2));
}

/**
 * @brief Get determinant matrix element.
 *
 * @param i Line index.
 * @param j Column index.
 *
 * @return Determinant matrix element as float.
 */
float kk_getdetelem(int i, int j) {
	return to_float(IORD_32DIRECT(KK_ACCEL_BASE, (0x30000 | ((i << 8) & 0xff00) | (j & 0xff)) << 2));
}

/**
 * @brief Print a matrix.
 *
 * @param matrix N-by-N matrix.
 */
void print_matrix(float matrix[N][N]) {
	int i, j;
	for(i = 0; i < N; i++) {
		for(j = 0; j < N; j++) {
			printf("\t %.2f", matrix[i][j]);
		}
		printf("\n");
	}
	printf("\n");
}

/**
 * @brief Multiply two matrices.
 *
 * @param A First N-by-N matrix.
 * @param B Second N-by-N matrix.
 * @param C Result N-by-N matrix.
 */
void multiply_matrix(float A[N][N], float B[N][N], float C[N][N]) {
	int i, j, k;
	for(i = 0; i < N; i++) {
		for(j = 0; j < N; j++) {
			C[i][j] = 0;
			for(k = 0; k < N; k++)
				C[i][j] += A[i][k] * B[k][j];
		}
	}
}

/**
 * @brief Calculate error distance between calculated identity and true identity.
 *
 * @param matrix N-by-N matrix.
 *
 * @return Error distance. Less is better.
 */
float calculate_error(float matrix[N][N]) {
	int i, j;
	float val = 0;

	for(i = 0; i < N; i++) {
		for(j = 0; j < N; j++) {
			val += fabs(((i == j)? 1 : 0) - matrix[i][j]);
		}
	}

	val /= N * N;

	return val;
}

/**
 * @brief Run KK Algorithm.
 */
void the_algorithm(void) {
#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp variables */
	alt_u32 then[5], now[5];
#endif

#if N == 3
	/* 3 x 3 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1},
								{1, 2, 4},
								{1, 3, 9}
							};
#elif N == 4
	/* 4 x 4 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1},
								{1, 2, 4, 8},
								{1, 3, 9, 27},
								{1, 4, 16, 64}
							};
#elif N == 5
	/* 5 x 5 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16},
								{1, 3, 9, 27, 81},
								{1, 4, 16, 64, 256},
								{1, 5, 25, 125, 625}
							};
#elif N == 6
	/* 6 x 6 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16, 32},
								{1, 3, 9, 27, 81, 243},
								{1, 4, 16, 64, 256, 1024},
								{1, 5, 25, 125, 625, 3125},
								{1, 6, 36, 216, 1296, 7776}
							};
#elif N == 7
	/* 7 x 7 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16, 32, 64},
								{1, 3, 9, 27, 81, 243, 729},
								{1, 4, 16, 64, 256, 1024, 4096},
								{1, 5, 25, 125, 625, 3125, 15625},
								{1, 6, 36, 216, 1296, 7776, 46656},
								{1, 7, 49, 343, 2401, 16807, 117649}
							};
#elif N == 8
	/* 8 x 8 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16, 32, 64, 128},
								{1, 3, 9, 27, 81, 243, 729, 2187},
								{1, 4, 16, 64, 256, 1024, 4096, 16384},
								{1, 5, 25, 125, 625, 3125, 15625, 78125},
								{1, 6, 36, 216, 1296, 7776, 46656, 279936},
								{1, 7, 49, 343, 2401, 16807, 117649, 823543},
								{1, 8, 64, 512, 4096, 32768, 262144, 2097152}
							};
#elif N == 9
	/* 9 x 9 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1, 1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16, 32, 64, 128, 256},
								{1, 3, 9, 27, 81, 243, 729, 2187, 6561},
								{1, 4, 16, 64, 256, 1024, 4096, 16384, 65536},
								{1, 5, 25, 125, 625, 3125, 15625, 78125, 390625},
								{1, 6, 36, 216, 1296, 7776, 46656, 279936, 1679616},
								{1, 7, 49, 343, 2401, 16807, 117649, 823543, 5764801},
								{1, 8, 64, 512, 4096, 32768, 262144, 2097152, 16777216},
								{1, 9, 81, 729, 6561, 59049, 531441, 4782969, 43046721}
							};
#elif N == 10
	/* 10 x 10 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16, 32, 64, 128, 256, 512},
								{1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683},
								{1, 4, 16, 64, 256, 1024, 4096, 16384, 65536, 262144},
								{1, 5, 25, 125, 625, 3125, 15625, 78125, 390625, 1953125},
								{1, 6, 36, 216, 1296, 7776, 46656, 279936, 1679616, 10077696},
								{1, 7, 49, 343, 2401, 16807, 117649, 823543, 5764801, 40353607},
								{1, 8, 64, 512, 4096, 32768, 262144, 2097152, 16777216, 134217728},
								{1, 9, 81, 729, 6561, 59049, 531441, 4782969, 43046721, 387420489},
								{1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000}
							};
#elif N == 11
	/* 11 x 11 Vandermonde Matrix */
	float matrix_O[N][N] = {
								{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024},
								{1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683, 59049},
								{1, 4, 16, 64, 256, 1024, 4096, 16384, 65536, 262144, 1048576},
								{1, 5, 25, 125, 625, 3125, 15625, 78125, 390625, 1953125, 9765625},
								{1, 6, 36, 216, 1296, 7776, 46656, 279936, 1679616, 10077696, 60466176},
								{1, 7, 49, 343, 2401, 16807, 117649, 823543, 5764801, 40353607, 282475249},
								{1, 8, 64, 512, 4096, 32768, 262144, 2097152, 16777216, 134217728, 1073741824},
								{1, 9, 81, 729, 6561, 59049, 531441, 4782969, 43046721, 387420489, 3486784401},
								{1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 10000000000},
								{1, 11, 121, 1331, 14641, 161051, 1771561, 19487171, 214358881, 2357947691, 25937424601}
							};
#endif

	/* Matrix scratchpad */
	float matrix_K[3][N][N];
	/* Calculated identity matrix based on calculated inverted matrix */
	float matrix_IC[N][N];
	/* Error distance from true identity */
	float error;
	/* Auxiliary variables */
	int i, j, next = ((N + 2) % 3), prev = (N % 3), curr = (N + 1) % 3;

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Transfer matrix */
	then[0] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Start performance counter: Transfer matrix */
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, 1);
#endif

	/* Transfer matrix */
	for(i = 0; i < N; i++)
		for(j = 0; j < N; j++)
			kk_putelem(matrix_O[i][j], i, j);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Transfer matrix */
	now[0] = alt_timestamp();

	/* Timestamp before: KK Iterations */
	then[1] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Stop performance counter: Transfer matrix */
	PERF_END(PERFORMANCE_COUNTER_BASE, 1);

	/* Start performance counter: KK Iterations */
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, 2);
#endif

	/* Start and wait for custom hardware to finish */
	kk_start();
	while(kk_isrunning());

	/* Get elements */
	for(i = 0; i < N; i++) {
		for(j = 0; j < N; j++) {
			matrix_K[prev][i][j] = kk_getintelem(i, j);
			matrix_K[curr][i][j] = kk_getdetelem(i, j);
		}
	}

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: KK Iterations */
	now[1] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Stop performance counter: KK Iterations */
	PERF_END(PERFORMANCE_COUNTER_BASE, 2);
#endif

	/* Print intermediate matrix */
	printf("################################################\n");
	printf("Matrix K+1: K = %d\n", N);
	print_matrix(matrix_K[curr]);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Final iteration */
	then[2] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Start performance counter: Final iteration */
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, 3);
#endif

	/* Final iteration: Calculate inverse */
	for(i = 0; i < N; i++)
		for(j = 0; j < N; j++)
				matrix_K[next][i][j] = (matrix_K[prev][(j + 1) % N][(i + 1) % N] / matrix_K[curr][i][j]);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Final iteration */
	now[2] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Stop performance counter: Final iteration */
	PERF_END(PERFORMANCE_COUNTER_BASE, 3);
#endif

	/* Print inverted matrix */
	printf("################################################\n");
	printf("Inverted matrix:\n");
	print_matrix(matrix_K[next]);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Calculate identity */
	then[3] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Start performance counter: Calculate identity */
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, 4);
#endif

	/* Calculate identity */
	multiply_matrix(matrix_K[next], matrix_O, matrix_IC);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Calculate identity */
	now[3] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Stop performance counter: Calculate identity */
	PERF_END(PERFORMANCE_COUNTER_BASE, 4);
#endif

	/* Print calculated identity matrix */
	printf("################################################\n");
	printf("Calculated identity based on calculated inverted matrix:\n");
	print_matrix(matrix_IC);
	printf("################################################\n");

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Calculate error */
	then[4] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Start performance counter: Calculate error */
	PERF_BEGIN(PERFORMANCE_COUNTER_BASE, 5);
#endif

	/* Calculate error */
	error = calculate_error(matrix_IC);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Calculate error */
	now[4] = alt_timestamp();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Stop performance counter: Calculate error */
	PERF_END(PERFORMANCE_COUNTER_BASE, 5);
#endif

	/* Print error */
	printf("Error distance: %.8lf\n", error);

#ifdef ACTIVATE_TIMESTAMP
	/* Print timestamp report */
	printf("################################################\n");
	printf("Timestamp 0: Transfer matrix: %u ticks\n", now[0] - then[0]);
	printf("Timestamp 1: Iterations: %u ticks\n", now[1] - then[1]);
	printf("Timestamp 2: Final iteration: %u ticks\n", now[2] - then[2]);
	printf("Timestamp 3: Calculated identity: %u ticks\n", now[3] - then[3]);
	printf("Timestamp 4: Error distance: %u ticks\n", now[4] - then[4]);
#endif
}

/**
 * @brief Main function.
 */
int main(void) {
#ifdef ACTIVATE_TIMESTAMP
	/* Start timestamp counter */
	alt_timestamp_start();
#endif
#ifdef ACTIVATE_PERFCOUNT
	/* Reset and start global counter */
	PERF_RESET(PERFORMANCE_COUNTER_BASE);
	PERF_START_MEASURING(PERFORMANCE_COUNTER_BASE);
#endif

	/* Execute algorithm */
	the_algorithm();

#ifdef ACTIVATE_PERFCOUNT
	/* Stop global counter */
	PERF_STOP_MEASURING(PERFORMANCE_COUNTER_BASE);

	/* Print performance counter report */
	perf_print_formatted_report(PERFORMANCE_COUNTER_BASE, ALT_CPU_FREQ, 5,
							"Transfer matrix",
							"Iterations",
							"Last iteration",
							"Calculated identity",
							"Error distance");
#endif

	return 0;
}
