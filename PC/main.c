/* ********************************************************************************************* */
/* * KK-Algorithm for Strongly Non-Singular Matrices Inversion (PC Version)                    * */
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
#include <time.h>

/**
 * @brief Exact size of matrix.
 */
#define N 7

/**
 * @brief Uncomment this define to enable timestamp profiling.
 */
#define ACTIVATE_TIMESTAMP

/**
 * @brief Print a matrix.
 *
 * @param matrix N-by-N matrix.
 */
void print_matrix(double matrix[N][N]) {
	int i, j;
	for(i = 0; i < N ; i++) {
		for(j = 0; j < N; j++) {
			printf("\t %.2lf", matrix[i][j]);
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
void multiply_matrix(double A[N][N], double B[N][N], double C[N][N]) {
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
double calculate_error(double matrix[N][N]) {
	int i, j;
	double val = 0;

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
	clock_t then[5], now[5];
#endif

#if N == 3
	/* 3 x 3 Vandermonde Matrix */
	double matrix_O[N][N] = {
								{1, 1, 1},
								{1, 2, 4},
								{1, 3, 9}
							};
#elif N == 4
	/* 4 x 4 Vandermonde Matrix */
	double matrix_O[N][N] = {
								{1, 1, 1, 1},
								{1, 2, 4, 8},
								{1, 3, 9, 27},
								{1, 4, 16, 64}
							};
#elif N == 5
	/* 5 x 5 Vandermonde Matrix */
	double matrix_O[N][N] = {
								{1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16},
								{1, 3, 9, 27, 81},
								{1, 4, 16, 64, 256},
								{1, 5, 25, 125, 625}
							};
#elif N == 6
	/* 6 x 6 Vandermonde Matrix */
	double matrix_O[N][N] = {
								{1, 1, 1, 1, 1, 1},
								{1, 2, 4, 8, 16, 32},
								{1, 3, 9, 27, 81, 243},
								{1, 4, 16, 64, 256, 1024},
								{1, 5, 25, 125, 625, 3125},
								{1, 6, 36, 216, 1296, 7776}
							};
#elif N == 7
	/* 7 x 7 Vandermonde Matrix */
	double matrix_O[N][N] = {
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
	double matrix_O[N][N] = {
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
	double matrix_O[N][N] = {
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
	double matrix_O[N][N] = {
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
	double matrix_O[N][N] = {
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
	double matrix_K[3][N][N];
	/* Calculated identity matrix based on calculated inverted matrix */
	double matrix_IC[N][N];
	/* Error distance from true identity */
	double error;
	/* Auxiliary variables */
	int i, j, k, next = 0, prev = 1, curr = 2;

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Transfer matrix */
	then[0] = clock();
#endif

	/* Transfer matrix */
	for(i = 0; i < N; i++)
		for(j = 0; j < N; j++)
			matrix_K[curr][i][j] = matrix_O[i][j];

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Transfer matrix */
	now[0] = clock();

	/* Timestamp before: KK Iterations */
	then[1] = clock();
#endif

	/* KK iterations */
	for(k = 0; k < N-1; k++) {
		for(i = 0; i < N; i++) {
			for(j = 0; j < N; j++) {
				matrix_K[next][i % N][j % N] =
						(matrix_K[curr][i % N][j % N] * matrix_K[curr][(i + 1) % N][(j + 1) % N] - (matrix_K[curr][(i + 1) % N][j % N] * matrix_K[curr][i % N][(j + 1) % N])) /
						(k? (matrix_K[prev][(i + 1) % N][(j + 1) % N]) : 1.0);
			}
		}

		/* Refresh indexes */
		next = (next + 1) % 3;
		prev = (prev + 1) % 3;
		curr = (curr + 1) % 3;
	}

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: KK Iterations */
	now[1] = clock();
#endif

	/* Print intermediate matrix */
	printf("################################################\n");
	printf("Matrix K+1: K = %d\n", (k+1));
	print_matrix(matrix_K[curr]);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Final iteration */
	then[2] = clock();
#endif

	/* Final iteration: Calculate inverse */
	for(i = 0; i < N; i++)
		for(j = 0; j < N; j++)
				matrix_K[next][i][j] = (matrix_K[prev][(j + 1) % N][(i + 1) % N] / matrix_K[curr][i][j]);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Final iteration */
	now[2] = clock();
#endif

	/* Print inverted matrix */
	printf("################################################\n");
	printf("Inverted matrix:\n");
	print_matrix(matrix_K[next]);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Calculate identity */
	then[3] = clock();
#endif

	/* Calculate identity */
	multiply_matrix(matrix_K[next], matrix_O, matrix_IC);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Calculate identity */
	now[3] = clock();
#endif

	/* Print calculated identity matrix */
	printf("################################################\n");
	printf("Calculated identity based on calculated inverted matrix:\n");
	print_matrix(matrix_IC);
	printf("################################################\n");

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp before: Calculate error */
	then[4] = clock();
#endif

	/* Calculate error */
	error = calculate_error(matrix_IC);

#ifdef ACTIVATE_TIMESTAMP
	/* Timestamp after: Calculate error */
	now[4] = clock();
#endif

	/* Print error */
	printf("Error distance: %.8lf\n", error);

#ifdef ACTIVATE_TIMESTAMP
	/* Print timestamp report */
	printf("################################################\n");
	printf("Timestamp 0: Transfer matrix: %lu ticks\n", now[0] - then[0]);
	printf("Timestamp 1: Iterations: %lu ticks\n", now[1] - then[1]);
	printf("Timestamp 2: Final iteration: %lu ticks\n", now[2] - then[2]);
	printf("Timestamp 3: Calculated identity: %lu ticks\n", now[3] - then[3]);
	printf("Timestamp 4: Error distance: %lu ticks\n", now[4] - then[4]);
#endif
}

/**
 * @brief Main function.
 */
int main(void) {
	/* Execute algorithm */
	the_algorithm();

	return 0;
}
