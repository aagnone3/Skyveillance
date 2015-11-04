import processing.core.*;
import processing.data.*;
import java.io.*;

public class DataLogger {
 
  private PrintWriter data_log;
  private PrintWriter general_log;
  private boolean log_data;
  
  public DataLogger(boolean log_data) {
    this.log_data = log_data;
    if (log_data) {
      openLogs();
      writeLogHeaders();
    }
  }
  
  
  public void writeLogHeaders() {
    data_log.println("Pin Voltage A,Pin Voltage B,Pin Voltage C," +
                   "Distance A,Distance B,Distance C," +
                   "Position Estimate");
  }
  
  public void logData(String descriptor, FloatDict voltages) {
    logData(descriptor, voltages, null, -9999.0);
  }
  
  public void logData(String descriptor, FloatDict voltages, double[] distances, double position_estimate) {
    if (log_data) {
      // Log pin voltage values
       for (float val : voltages.values()) {
         data_log.print(val + ",");
       }
       // Log distances
       if (distances != null) {
         for (int i = 0; i < distances.length; i += 1) {
           data_log.print(distances[i] + ",");
         }
       } else {
         for (int i = 0; i < NUM_CLIENTS; i += 1) {
           data_log.print(0.0 + ",");
         }
       }

       data_log.print(position_estimate);
       data_log.println(); 
    }
  }
  
  public void openLogs() {
     String time = str(month()) + "_" + str(day()) + "_" +
             str(hour()) + "_" + str(minute()) + "_" +
             str(second());
     data_log = createWriter("Data/Data_Log_" + time + ".csv");
     general_log = createWriter("Data/General_Log_" + time + ".txt");
  }
  
  public void closeLogs() {
    data_log.flush();
    data_log.close();
    
    general_log.flush();
    general_log.close();
  }
}