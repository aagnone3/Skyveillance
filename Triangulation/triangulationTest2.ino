#include <triangulation.h>

// Triangulation script
// Written by Nico van Duijn
// Last rev. 9/13/15 6:40pm

void setup() {
  Serial.begin(9600);
}

void loop() {
  
  float antennas[4 * 3] = {
    0.0, 0.0, 0.0, // Coordinates of Antenna 1
    1.0, 0.0, 0.0, // Coordinates of Antenna 2
    1.0, 1.0, 0.0, // Coordinates of Antenna 3
    0.0, 1.0, 0.0  // Coordinates of Antenna 4...
  };
  float distances[4 * 1] =  {0.7, 0.7, 0.7, 0.7};
  float x[3 * 1]; // holds solution
  
  // Compute location of target
  triang.locate(4, antennas, distances, x);

  triang.Print(antennas, 4, 3, "antennas");
  triang.Print(distances, 4, 1, "distances");
  Serial.println("Solution given by function is:");
  triang.Print(x, 3, 1, "x");
  while (1) {}
}




