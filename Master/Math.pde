import java.lang.Math;

public final float LAMBDA = (float)(3e8 / 2.4e9);
public final float[] CONSTANTS = {28.97, 20.35, 22.02, 15.83};

public double voltageToDistance(float voltage, double constant) {
  //println(voltage);
  double db_voltage = (voltage / 0.0177) - 89;
  double power = (db_voltage - constant) / (float)20.0;
  //println(power);
  double distance = LAMBDA / (4 * PI * pow(10.0, (float)power) );
  //println(distance);
  return distance;
}

public double[] toDistances(float[] voltages) {
  // Create an array to hold the calculated values
  double[] distances = new double[NUM_CLIENTS];
  // Get the current pin voltages receieved from clients
 //float[] pin_voltages = data.valueArray();
 for (int i = 0; i < NUM_CLIENTS; i += 1) {
   // Convert each pin voltage to the corresponding distance
   distances[i] = voltageToDistance(voltages[i], CONSTANTS[i]);
 }
 return distances;
}

public void updateRunningAverage(float[] new_data_points) {
  for (int i = 0; i < NUM_CLIENTS; i += 1) {
    //averages.set(ips.get(i), 0.0);
    averages.set(ips.get(i),(averages.get(ips.get(i)) * num_data_points + new_data_points[i]) / (num_data_points + 1));
  }
}