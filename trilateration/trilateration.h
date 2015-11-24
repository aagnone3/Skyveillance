// trilateration.h

/*
*  trilateration.h Library
*
* Created by Nico van Duijn on 9/25/15
*
* A library implementing trilateration on the Arduino platform.
*
* Solves the general problem of finding the coordinates of an unknown point when
* measured distances to a number (>=3) of know reference points are available.
* These can be absolute or relative distances. Note, however, that by using
* relative distances one degree of freedom is lost, which means one extra measurement
* is needed to obtain the same results/accuracy. 
*
* The library provides options for finding the unknown point by means of 
* linear least squares approximation (LLSQ), using an exact, linearized model
* of the problem as described here:
*
* http://inside.mines.edu/~whereman/talks/TurgutOzal-11-Trilateration.pdf
*
* The code used in this approach is heavily based on the MatrixMath library written by
* Charlie Matlack on 12/18/10 an RobH45345 on Arduino Forums, algorithm from
* NUMERICAL RECIPES: The Art of Scientific Computing, 
*
* http://playground.arduino.cc/Code/MatrixMath
*
* as well as an added QR factorization algorithm from 	
*
* http://www.keithlantz.net/2012/05/qr-decomposition-using-householder-transformations/
*
* Alternatively, the library provides a computationally more expensive, but more exact
* solution with an implementation of the Levenberg-Marquart algorithm to find the optimal
* solution using non-linear least squares. (NLLSQ). This part was taken and adjusted from
* files written by Ron Babich in May 2008 and can be found in original form here:
*
* https://gist.github.com/rbabich/3539146
*
*/

// Includes
#ifndef trilateration_h
#define trilateration_h

#if defined(ARDUINO) && ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif
#include <stdio.h>
#include <math.h>


// Function Prototypes
	void matrixPrint(double* A, int m, int n, String label);
	void matrixCopy(double* A, int n, int m, double* B);
	void matrixMult(double* A, double* B, int m, int p, int n, double* C);
	void matrixAdd(double* A, double* B, int m, int n, double* C);
	void matrixSub(double* A, double* B, int m, int n, double* C);
	void matrixTranspose(double* A, int m, int n, double* C);
	void matrixScale(double* A, int m, int n, double k);
	void QR(double* A, int m, int n, double* Q, double* R);
	void locateLLSQ(int numantennas, double* antennas, double* distances, double* x);
	void locateNLLSQ(int numantennas, double* antennas, double* distances, double* x);
	void locate(int numantennas, double* antennas, double* distances, double* x);
	void solveAxBCholesky(int n, double* l, double* x, double* b);
	void grad(double* gradient, double* params, int i, double* antennas);
	double func(double* params, int i, double* antennas);
	double dist(double x1, double y1, double z1, double x2, double y2, double z2);
	double errorFunc(double *par, int ny, double *y, double *dysq, double *fdata);
	int matrixInvert(double* A, int n);
	int levmarq(int npar, double *par, int ny, double *y, double *dysq, double *fdata);
	int choleskyDecomp(int n, double* l, double* a);

#endif
