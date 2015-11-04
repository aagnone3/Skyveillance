import java.lang.Math;

public final double LAMBDA = 3e8 / 2.4e9;
public final double JACKS_CONSTANT = 31.82858;

public double voltageToDistance(double voltage) {
  double db_voltage = (voltage / 0.0177) - 89;
  double power = (db_voltage - JACKS_CONSTANT)/20.0;
  double distance = LAMBDA / (4 * PI * pow(10.0, (float)power) );
  return distance;
}

public double[] toDistances(float[] voltages) {
  // Create an array to hold the calculated values
  double[] distances = new double[NUM_CLIENTS];
  // Get the current pin voltages receieved from clients
 float[] pin_voltages = data.valueArray();
 for (int i = 0; i < NUM_CLIENTS; i += 1) {
   // Convert each pin voltage to the corresponding distance
   distances[i] = voltageToDistance(pin_voltages[i]);
 }
 return distances;
}