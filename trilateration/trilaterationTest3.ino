#include <trilateration.h>

// Trilateration script
// Written by Nico van Duijn
// Last rev. 10/25/15 6:40pm

#define NUM 4
void setup() {
  Serial.begin(9600);
}

void loop() {
  
  double antennas[NUM * 3] = {//(#antennas)x3
    0.0, 0.0, 0.0, // Coordinates of Antenna 1
    10.0, 0.0, 0.0, // Coordinates of Antenna 2
    0.0, 10.0, 0.0, // Coordinates of Antenna 3
    10.0, 10.0, 1.0,  // Coordinates of Antenna 4...
  };
  double distances[NUM * 1] =  {4*6.7082, 4*10.247, 4*8.0623, 4*10.77};
  double x[4 * 1]; // holds solution
  
  // Compute location of target
  locateLLSQ(NUM, antennas, distances, x); //Bad performance for 4 antennas with relative distances

  matrixPrint(antennas, NUM, 3, "antennas");
  matrixPrint(distances, NUM, 1, "distances");
  Serial.println("Solution given by LLSQ function is:");
  matrixPrint(x, 4, 1, "x");
 
  // Initial guess for NLLSQ 
  x[0]=1.0; x[1]=3.0; x[2]=3.0; x[3]=4.0;
  
  locateNLLSQ(NUM, antennas, distances, x);
  Serial.println("Solution given by NLLSQ function is:");
  matrixPrint(x, 4, 1, "x");

    while (1) {}
}

