/**
 * Simple Read
 * 
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */


import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port
String last_val;
PrintWriter data_log;
PrintWriter general_log;
final int NUM_DATA_POINTS = 2000;
int cur_num_data_points;

void setup() 
{
  cur_num_data_points = 0;
  size(200, 200);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  data_log = createWriter("Data Log.csv");
  general_log = createWriter("General Log.txt");
  String portName = "COM1";
  for (String port : Serial.list()) {
    if (port.equals("COM4")) {
      portName = port;
    }
  }
  myPort = new Serial(this, portName, 9600);
  println("Ready");
}

void draw()
{
  if (myPort.available() > 0) {  // If data is available,
    last_val = val;
    val = myPort.readStringUntil('\n');         // read it and store it in val
  }

  if (val != null && !val.equals(last_val)) {
    //if (val.indexOf(",") > -1) {
      // If comma is found (i.e. data message)
      if (cur_num_data_points < NUM_DATA_POINTS) {
        println(val);
        data_log.print(val);
        general_log.print(val);
        ++cur_num_data_points;
      } else if (cur_num_data_points == NUM_DATA_POINTS) {
        println("Done logging.");
        data_log.flush();
        data_log.close();
        general_log.flush();
        general_log.close();
        ++cur_num_data_points;
      }
    //} else {
    //  general_log.println(val);
    //} 
  }
}

void stop() {
  println("Yep");
  data_log.flush();
  data_log.close();
  
  general_log.flush();
  general_log.close();
}



/*

// Wiring / Arduino Code
// Code for sensing a switch status and writing the value to the serial port.

int switchPin = 4;                       // Switch connected to pin 4

void setup() {
  pinMode(switchPin, INPUT);             // Set pin 0 as an input
  Serial.begin(9600);                    // Start serial communication at 9600 bps
}

void loop() {
  if (digitalRead(switchPin) == HIGH) {  // If switch is ON,
    Serial.write(1);               // send 1 to Processing
  } else {                               // If the switch is not ON,
    Serial.write(0);               // send 0 to Processing
  }
  delay(100);                            // Wait 100 milliseconds
}

*/