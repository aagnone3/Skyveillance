
void setup() {
final int NUM = 4;

double[] antennas = new double[NUM * 3];//(#antennas)x3
antennas[0] = 0.0; // Coordinates of Antenna 1
antennas[1] = 0.0; // Coordinates of Antenna 1
antennas[2] = 0.0; // Coordinates of Antenna 1

antennas[3] = 10.0; // Coordinates of Antenna 2
antennas[4] = 0.0; // Coordinates of Antenna 2
antennas[5] = 0.0; // Coordinates of Antenna 2

antennas[6] = 0.0; // Coordinates of Antenna 3
antennas[7] = 10.0; // Coordinates of Antenna 3
antennas[8] = 0.0; // Coordinates of Antenna 3

antennas[9] = 10.0; // Coordinates of Antenna 4
antennas[10] = 10.0; // Coordinates of Antenna 4
antennas[11] = 1.0; // Coordinates of Antenna 4

double[] distances = new double[NUM * 1];
float factor = 0.5;
distances[0] = factor * 6.7082;
distances[1] = factor * 10.247;
distances[2] = factor * 8.0623;
distances[3] = factor * 10.77;

double[] x = new double[4 * 1]; // holds solution


// Compute location of target
locateLLSQ(NUM, antennas, distances, x); //Bad performance for 4 antennas with relative distances

matrixPrint(antennas, NUM, 3, "antennas");
matrixPrint(distances, NUM, 1, "distances");

// Linear
println();
matrixPrint(x, 4, 1, "Linear Estimation");

// Nonlinear
// Initial guess
x[0]=1.0; x[1]=3.0; x[2]=3.0; x[3]=4.0;
locateNLLSQ(NUM, antennas, distances, x);
matrixPrint(x, 4, 1, "Nonlinear Estimation");
}

void draw() {
  
}