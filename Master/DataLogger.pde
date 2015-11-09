import processing.core.*;
import processing.data.*;
import java.io.*;

public class DataLogger {
 
  private PrintWriter data_log;
  private boolean log_data;
  
  public DataLogger(boolean log_data) {
    this.log_data = log_data;
    if (log_data) {
      openLogs();
      writeLogHeaders();
    }
  }
  
  
  public void writeLogHeaders() {
    String pin_voltage_headers = "",
           distance_headers = "";
    for (int i = 0; i < NUM_CLIENTS; i += 1) {
      pin_voltage_headers += "Pin Voltage " + char(65 + i) + ",";
      distance_headers += "Distance " + char(65 + i) + ",";
    }
    
    data_log.println(pin_voltage_headers + distance_headers + "Position Estimate");
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
    // Get timestamp that will be prepended to whatever filename the user chooses
     String time = str(month()) + "_" + str(day()) + "_" +
             str(hour()) + "_" + str(minute()) + "_" +
             str(second());
    // Get user string to add to the filenamefrom the user
    String description = (String) javax.swing.JOptionPane.showInputDialog(null,
                                          "Give a short description on the data being logged.",
                                          "");
    data_log = createWriter("Data/" + time + "_" + description + ".csv");
     
    if (data_log == null) {
      println("Failed to create log file. You probably gave an inapprorpiate character in the description.");
    }
  }
  
  public void closeLogs() {
    data_log.flush();
    data_log.close();
  }
}