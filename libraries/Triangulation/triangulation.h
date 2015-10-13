/*
 *  triangulation.h Library 
 *
 *  Created by Nico van Duijn on 9/13/15
 *
 *  Modified from code by Charlie Matlack on 12/18/10. and 
 * RobH45345 on Arduino Forums, algorithm from 
 *  NUMERICAL RECIPES: The Art of Scientific Computing.
 */

#ifndef triangulation_h
#define triangulation_h

#if defined(ARDUINO) && ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif

class triangulation
{
public:
	//triangulation();
	void Print(float* A, int m, int n, String label);
	void Copy(float* A, int n, int m, float* B);
	void Multiply(float* A, float* B, int m, int p, int n, float* C);
	void Add(float* A, float* B, int m, int n, float* C);
	void Subtract(float* A, float* B, int m, int n, float* C);
	void Transpose(float* A, int m, int n, float* C);
	void Scale(float* A, int m, int n, float k);
	void QR(float* A, int m, int n, float* Q, float* R);
	void locate(int numantennas, float* antennas, float* distances, float* x);
	int Invert(float* A, int n);
	float dist(float x1, float y1, float z1, float x2, float y2, float z2);
};

extern triangulation triang;
#endif