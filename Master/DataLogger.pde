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
      pin_voltage_headers += "V_ " + char(65 + i) + ",";
      distance_headers += "Dist " + char(65 + i) + ",";
    }
    
    data_log.println(pin_voltage_headers + distance_headers
        + "X (NL),Y (NL),Z (NL),Error (NL),X (L),Y (L),Z (L),Error (L)");
  }
  
  public void logData(String descriptor, FloatDict voltages) {
    logData(descriptor, voltages, null, null, null);
  }
  
  public void logData(String descriptor, FloatDict voltages, double[] distances, double[] nonlinear_results, double[] linear_results) {
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

       // Log nonlinear least-squares triangulation results if available
       if (nonlinear_results != null) {
         data_log.print(nonlinear_results[0] + "," + nonlinear_results[1] + "," + nonlinear_results[2]
                        + "," + nonlinear_results[3] + ",");
       } else {
         data_log.print(",,,,");
       }
       
       // Log linear least-squares triangulation results if available
       if (linear_results != null) {
         data_log.print(linear_results[0] + "," + linear_results[1] + "," + linear_results[2]
                        + "," + linear_results[3] + ",");
       } else {
         data_log.print(",,,,");
       }
       
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