/*
 *  triangulation.cpp Library 
 *
 *  Created by Nico van Duijn on 9/13/15
 *
 * 
 *  Modified from code by Charlie Matlack on 12/18/10 and RobH45345 on Arduino Forums
 *  NUMERICAL RECIPES: The Art of Scientific Computing.
 * 
 * 
 * Added QR factorization algorithm to MatrixMath.h
 *
 */

#include "triangulation.h"

#define NR_END 1

triangulation triang;			// Pre-instantiate

// Matrix Printing Routine
// Uses tabs to separate numbers under assumption printed float width won't cause problems
void triangulation::Print(float* A, int m, int n, String label){
	// A = input matrix (m x n)
	int i,j;
	Serial.println();
	Serial.println(label);
	for (i=0; i<m; i++){
		for (j=0;j<n;j++){
			Serial.print(A[n*i+j]);
			Serial.print("\t");
		}
		Serial.println();
	}
}

void triangulation::Copy(float* A, int n, int m, float* B)
{
	int i, j, k;
	for (i=0;i<m;i++)
		for(j=0;j<n;j++)
		{
			B[n*i+j] = A[n*i+j];
		}
}

//Matrix Multiplication Routine
// C = A*B
void triangulation::Multiply(float* A, float* B, int m, int p, int n, float* C)
{
	// A = input matrix (m x p)
	// B = input matrix (p x n)
	// m = number of rows in A
	// p = number of columns in A = number of rows in B
	// n = number of columns in B
	// C = output matrix = A*B (m x n)
	int i, j, k;
	for (i=0;i<m;i++)
		for(j=0;j<n;j++)
		{
			C[n*i+j]=0;
			for (k=0;k<p;k++)
				C[n*i+j]= C[n*i+j]+A[p*i+k]*B[n*k+j];
		}
}


//Matrix Addition Routine
void triangulation::Add(float* A, float* B, int m, int n, float* C)
{
	// A = input matrix (m x n)
	// B = input matrix (m x n)
	// m = number of rows in A = number of rows in B
	// n = number of columns in A = number of columns in B
	// C = output matrix = A+B (m x n)
	int i, j;
	for (i=0;i<m;i++)
		for(j=0;j<n;j++)
			C[n*i+j]=A[n*i+j]+B[n*i+j];
}


//Matrix Subtraction Routine
void triangulation::Subtract(float* A, float* B, int m, int n, float* C)
{
	// A = input matrix (m x n)
	// B = input matrix (m x n)
	// m = number of rows in A = number of rows in B
	// n = number of columns in A = number of columns in B
	// C = output matrix = A-B (m x n)
	int i, j;
	for (i=0;i<m;i++)
		for(j=0;j<n;j++)
			C[n*i+j]=A[n*i+j]-B[n*i+j];
}


//Matrix Transpose Routine
void triangulation::Transpose(float* A, int m, int n, float* C)
{
	// A = input matrix (m x n)
	// m = number of rows in A
	// n = number of columns in A
	// C = output matrix = the transpose of A (n x m)
	int i, j;
	for (i=0;i<m;i++)
		for(j=0;j<n;j++)
			C[m*j+i]=A[n*i+j];
}

void triangulation::Scale(float* A, int m, int n, float k)
{
	for (int i=0; i<m; i++)
		for (int j=0; j<n; j++)
			A[n*i+j] = A[n*i+j]*k;
}


//Matrix Inversion Routine
// * This function inverts a matrix based on the Gauss Jordan method.
// * Specifically, it uses partial pivoting to improve numeric stability.
// * The algorithm is drawn from those presented in 
//	 NUMERICAL RECIPES: The Art of Scientific Computing.
// * The function returns 1 on success, 0 on failure.
// * NOTE: The argument is ALSO the result matrix, meaning the input matrix is REPLACED
int triangulation::Invert(float* A, int n)
{
	// A = input matrix AND result matrix
	// n = number of rows = number of columns in A (n x n)
	int pivrow;		// keeps track of current pivot row
	int k,i,j;		// k: overall index along diagonal; i: row index; j: col index
	int pivrows[n]; // keeps track of rows swaps to undo at end
	float tmp;		// used for finding max value and making column swaps

	for (k = 0; k < n; k++)
	{
		// find pivot row, the row with biggest entry in current column
		tmp = 0;
		for (i = k; i < n; i++)
		{
			if (abs(A[i*n+k]) >= tmp)	// 'Avoid using other functions inside abs()?'
			{
				tmp = abs(A[i*n+k]);
				pivrow = i;
			}
		}

		// check for singular matrix
		if (A[pivrow*n+k] == 0.0f)
		{
			//Serial.println("Inversion failed due to singular matrix");
			return 0;
		}

		// Execute pivot (row swap) if needed
		if (pivrow != k)
		{
			// swap row k with pivrow
			for (j = 0; j < n; j++)
			{
				tmp = A[k*n+j];
				A[k*n+j] = A[pivrow*n+j];
				A[pivrow*n+j] = tmp;
			}
		}
		pivrows[k] = pivrow;	// record row swap (even if no swap happened)

		tmp = 1.0f/A[k*n+k];	// invert pivot element
		A[k*n+k] = 1.0f;		// This element of input matrix becomes result matrix

		// Perform row reduction (divide every element by pivot)
		for (j = 0; j < n; j++)
		{
			A[k*n+j] = A[k*n+j]*tmp;
		}

		// Now eliminate all other entries in this column
		for (i = 0; i < n; i++)
		{
			if (i != k)
			{
				tmp = A[i*n+k];
				A[i*n+k] = 0.0f;  // The other place where in matrix becomes result mat
				for (j = 0; j < n; j++)
				{
					A[i*n+j] = A[i*n+j] - A[k*n+j]*tmp;
				}
			}
		}
	}

	// Done, now need to undo pivot row swaps by doing column swaps in reverse order
	for (k = n-1; k >= 0; k--)
	{
		if (pivrows[k] != k)
		{
			for (i = 0; i < n; i++)
			{
				tmp = A[i*n+k];
				A[i*n+k] = A[i*n+pivrows[k]];
				A[i*n+pivrows[k]] = tmp;
			}
		}
	}
	return 1;
}

// QR Factorization
// Not a very efficient approach, but simple and effective
// Written by Nico van Duijn, 9/13/2015
// Source of algorithm (adjusted by me):
// http://www.keithlantz.net/2012/05/qr-decomposition-using-householder-transformations/
void triangulation::QR(float* A, int m, int n, float* Q, float* R) {
	// A is the (m*n) matrix to be factorized A=Q*R

	float mag, alpha;
	float u[m], v[m], vtrans[m];
	float P[m * m], I[m * m], vvtrans[m * m], Rbackup[m * m], Qbackup[m * m];
	triang.Copy(A, m, m, R); // Initialize R to A

	// Initialize Q, P, I to Identity
	for (int i = 0; i < m * m; i++)Q[i] = 0;
	for (int i = 0; i < m; i++)Q[i * n + i] = 1;
	for (int i = 0; i < m * m; i++)P[i] = 0;
	for (int i = 0; i < m; i++)P[i * n + i] = 1;
	for (int i = 0; i < m * m; i++)I[i] = 0;
	for (int i = 0; i < m; i++)I[i * n + i] = 1;

	for (int i = 0; i < n; i++) {//loop through all columns
		for (int q = 0; q < m; q++)u[q] = 0; // set u and v to zero
		for (int q = 0; q < m; q++)v[q] = 0;

		mag = 0.0; //set mag to zero

		for (int j = i; j < m; j++) {
			u[j] = R[j * n + i];
			mag += u[j] * u[j];
		}
		mag = sqrt(mag);

		alpha = u[i] < 0 ? mag : -mag;

		mag = 0.0;
		for (int j = i; j < m; j++) {
			v[j] = j == i ? u[j] + alpha : u[j];
			mag += v[j] * v[j];
		}
		mag = sqrt(mag);

		if (mag < 0.0000000001) continue;

		for (int j = i; j < m; j++) v[j] /= mag;

		// P = I - (v * v.transpose()) * 2.0;
		triang.Transpose(v, m, 1, vtrans);
		triang.Multiply(v, vtrans, m, 1, m, vvtrans);
		triang.Scale(vvtrans, m, m, 2.0);
		triang.Subtract(I, vvtrans, m, m, P);

		// R = P * R;
		triang.Multiply(P, R, m, m, m, Rbackup);
		triang.Copy(Rbackup, m, m, R);

		//Q = Q * P;
		triang.Multiply(Q, P, m, m, m, Qbackup);
		triang.Copy(Qbackup, m, m, Q);
	}

}

void triangulation::locate(int numantennas, float* antennas, float* distances, float* x) {
	// function saves triangulated position in vector x
	// input *antennas holds
	// x1, y1, z1,
	// x2, y2, z2,
	// x3, y3, z3,
	// x4, y4, z4;
	// numantennas holds integer number of antennas (min 4)
	// float *distances holds pointer to array holding distances from each antenna
	// Theory used:
	// http://inside.mines.edu/~whereman/talks/TurgutOzal-11-Trilateration.pdf

	// define some locals
	int m = (numantennas - 1); // Number of rows in A
	int n = 3; // Number of columns in A (always three)
	float A[m * n];
	float b[m * 1];
	float r;
	float Atranspose[n * m];
	float AtAinA[n * m];
	float AtA[n * n];

	//Calculating b vector
	for (int i = 0; i < m; i++) {
		r = triang.dist(antennas[0], antennas[1], antennas[2], antennas[(i + 1) * n], antennas[(i + 1) * n + 1], antennas[(i + 1) * n + 2]);
		b[i] = 0.5 * (distances[0] * distances[0] - distances[i + 1] * distances[i + 1] + r * r);
	}

	//Calculating A triang
	for (int i = 0; i < m; i++) {
		A[i * n] = antennas[(i + 1) * n] - antennas[0];         //xi-x1
		A[i * n + 1] = antennas[(i + 1) * n + 1] - antennas[1]; //yi-y1
		A[i * n + 2] = antennas[(i + 1) * n + 2] - antennas[2]; //zi-z1
	}

	triang.Transpose(A, m, n, Atranspose);
	triang.Multiply(Atranspose, A, n, m, n, AtA);

	if (triang.Invert(AtA, 3) == 1) { //well behaved
		triang.Multiply(AtA, Atranspose, n, n, m, AtAinA);
		triang.Multiply(AtAinA, b, n, m, 1, x);

	}
	else {    // Ill-behaved A

		float Q[m * m], Qtranspose[m * m], Qtransposeb[m * 1];
		float R[m * m];
		triang.QR(A, m, n, Q, R);
		triang.Transpose(Q, m, m, Qtranspose);
		triang.Multiply(Qtranspose, b, m, m, 1, Qtransposeb);
		triang.Invert(R, m);
		triang.Multiply(R, Qtransposeb, m, m, 1, x);
	}

	// Adding back the reference point
	x[0] = x[0] + antennas[0];
	x[1] = x[1] + antennas[1];
	x[2] = x[2] + antennas[2];
}

float triangulation::dist(float x1, float y1, float z1, float x2, float y2, float z2) {
	// Function to compute distance between two points
	return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1));
}