 //
 import hypermedia.net.*;
 
 // Window width
 int WINDOW_WIDTH;
 // Window height
int WINDOW_HEIGHT;
 // Number of clients
 final int NUM_CLIENTS = 4;
 // Port number to send to for all clients
 final int DEST_PORT_NUM = 8888;
 // Timeout in ms for waiting for client responses to setting the noise floor
 final int NOISE_FLOOR_TIMEOUT_MS = 7000;
 // Timeout in ms for waiting for client responses for data
 final int DATA_TIMEOUT_MS = 300;
 // Flag to indicate whether or not we want to log data
 final boolean LOG_DATA = true;
 //
 final int NUM_POINTS_PER_AVERAGE = 5;
 //
 final int LOOP_DELAY = 120;
 //
 final float LOOP_FREQ = 1.0 / LOOP_DELAY;
 
 // UDP Handler
 UDP udp;
 // Indication of having received all responses from clients for a specific time window
 boolean got_all_responses;
 // List of IP addresses of all clients
 ArrayList<String> ips;
 // List of IP addresses we have received a response from
 ArrayList<String> rcvd;
 // List of float data values received from clients
 //FloatList data;
 // Map of a client's IP address to the index in the data array where its data should be stored
 FloatDict data;
 // Handle for logging data
 DataLogger logger;
 // Simple counter for displaying different numbers of characters for serial line separators
 // This makes it easier to know that the data values have been updated, in the event that all values
 // are equal to previous values
 int line_sep_count;
 //
 double[] distances;
 //
 FloatDict averages;
 // Solution vector for the NLLSQ triangulation algorithm
 double[] x_nll;
 // Solution vector for the LLSQ triangulation algorithm
 double[] x_ll;
 // Antenna locations
 double[] antennas;
 //
 int num_data_points;
 //
 boolean poll_data;


 void setup() {
   size(1000, 800);
   WINDOW_WIDTH = 1000;
   WINDOW_HEIGHT = 1000;
   
   poll_data = false;
   
   udp = new UDP( this, 6000 );  // create a new datagram connection on port 6000
   udp.listen(true);           // and wait for incoming message
   
   rcvd = new ArrayList<String>();
   
   // IP Addresses
   ips = new ArrayList<String>();
   ips.add("192.168.1.1");
   ips.add("192.168.1.2");
   ips.add("192.168.1.3");
   ips.add("192.168.1.4");
   
   got_all_responses = false;
   line_sep_count = 0;
   
   // Initialize data to defaults
   data = new FloatDict();
   for (int i = 0; i < NUM_CLIENTS; i += 1) {
     data.set(ips.get(i), -999.0);
   }
   
   // Initialize data for the triangulation algo
   distances = new double[NUM_CLIENTS];
   averages = new FloatDict();
   for (int i = 0; i < NUM_CLIENTS; i += 1) {
     averages.set(ips.get(i), 0.0);
   }

   x_nll = new double[4];
   x_ll = new double[4];
   
   // Antenna locations
   if (NUM_CLIENTS >= 4) {
     antennas = new double[NUM_CLIENTS * 3];
     antennas[0] = 0.0;   // Coordinates of Antenna 1
     antennas[1] = 0.0;   // Coordinates of Antenna 1
     antennas[2] = 0.0;   // Coordinates of Antenna 1
    
     antennas[3] = 0.9652;  // Coordinates of Antenna 2
     antennas[4] = 0.0;   // Coordinates of Antenna 2
     antennas[5] = 0.0;   // Coordinates of Antenna 2
    
     antennas[6] = 0.0;   // Coordinates of Antenna 3
     antennas[7] = 0.9652;  // Coordinates of Antenna 3
     antennas[8] = 0.7366;   // Coordinates of Antenna 3
    
     antennas[9] = 0.9652;  // Coordinates of Antenna 4
     antennas[10] = 0.9652; // Coordinates of Antenna 4
     antennas[11] = 0.0;  // Coordinates of Antenna 4
   }
   
   logger = new DataLogger(LOG_DATA);
   initDisplay(LOG_DATA);
 }

 // Do nothing automatically. Behavior is triggered via key presses.
 // See keyPressed() for more details.
 void draw() {
   if (poll_data) {
       //delay(LOOP_DELAY);
       delay(500);
       
       printSeparator();

       // Poll all clients for data values
       sendRequestsForData();
     
       // Only perform data operations if all client responses were successfully received
       //if (dataSuccessfullyCollected(DATA_TIMEOUT_MS)) {
         // Convert pin voltages to distances
         float[] values = data.valueArray();
         values[0] -= 0.3;
         //double[] distances = toDistances(values);
  
         // TODO remove random values after testing
         //float[] random = new float[NUM_CLIENTS];
         //for (int i = 0; i < random.length; i += 1) {
         //  random[i] = 0.8 + (float)(Math.random() * 1.0);
         //}
         float[] custom = new float[4];
         custom[0] = 1.1;
         custom[1] = 1.1;
         custom[2] = 1.1;
         custom[3] = 1.0;
         values = custom;

         updatePositionEstimate(values);
         
         // Update plot with results
         plotPinVoltages(values);
         //plotDistances(distances);
  
         // Log data
         logger.logData("Everything", averages, distances, null, null);
       //}
   }
 }
 
 void estimatePosition() {
   ll_estimate(distances);
   nll_estimate(distances);
 }
 
 // Called only when 's' or 'S' key entered
 void loop() {
   
   // Remain in an infinite loop, with only interrupt functions to alter code flow
   while (true) {

   }
 }
 
 void ll_estimate(double[] distances) {
   locateLLSQ(NUM_CLIENTS, antennas, distances, x_ll); // Bad performance for 4 antennas with relative distances
   println();
   println("Solution given by LLSQ function is:");
   matrixPrint(x_ll, 4, 1, "x (linear)");
 }
 
 void nll_estimate(double[] distances) {
   // Initial guess for NLLSQ
   x_nll[0] = 1.0;
   x_nll[1] = 3.0;
   x_nll[2] = 3.0;
   x_nll[3] = 4.0;
   
   locateNLLSQ(NUM_CLIENTS, antennas, distances, x_nll);
   println();
   println("Solution given by NLLSQ function is:");
   matrixPrint(x_nll, 4, 1, "x (nonlinear)");
 }
 
 void sendRequestsForData() {
   // Clear list of ip's we have received data from
   rcvd.clear();
   got_all_responses = false;
    
   // Send new requests for data to all clients
   for (String ip : ips) {
     udp.send(H_REQ_PIN_VOLTAGE + "|", ip, DEST_PORT_NUM );
   }
 }
 
 boolean dataSuccessfullyCollected(int timeout) {
   int start_time = millis();
   while(!got_all_responses) {
     if (millis() - start_time > timeout) {
       // Timeout case
       // Announce the timeout, and return false to repoll for data
       for (int i = 0; i < NUM_CLIENTS; i += 1) {
         if (!rcvd.contains(ips.get(i))) {
           println("Missing " + ips.get(i));
         }
       }
       println("Timeout!");
       return false;
     }
     delay(20);
   }
   
   // Return true to indicate that all data was successfully received
   return true;
 }

 void receive(byte[] rcvd_data, String ip, int port) {
   //print(ip);
   if (rcvd_data.length == 10 && !rcvd.contains(ip)) {
     //println("...good");
     // Add ip to the received list
     //println(ip);
     rcvd.add(ip);
     float reading = bytesToFloat(rcvd_data, 4);
     data.set(ip, reading);
       
     // Check to see if we have data from all clients
     if (rcvd.size() == NUM_CLIENTS) {
       got_all_responses = true;
     }
   } else {
     //println(str(rcvd_data));
   }
 }
 
 float bytesToFloat(byte[] raw, int offset) {
   String hex_int = hex(raw[offset + 3]) + hex(raw[offset + 2])
                    + hex(raw[offset + 1]) + hex(raw[offset]);
   return Float.intBitsToFloat(unhex(hex_int));
 }
 
 void setNoiseFloors() {
   println("Clients are setting noise floors...");
   
   // Send new requests for data to all clients
   rcvd.clear();
   for (String ip : ips) {
     udp.send(H_REQ_NOISE_FLOOR + "|", ip, DEST_PORT_NUM );
   }
   
   // Recursively try to set noise floors
   if (!dataSuccessfullyCollected(NOISE_FLOOR_TIMEOUT_MS)) {
     println("Failed to get noise floor responses from all clients. Retrying...");
     rcvd.clear();
     setNoiseFloors();
   }
 }
 
  void keyPressed() {
    if (key == 'n' || key == 'N') {
      setNoiseFloors();
      logger.logData("Noise Floor", data);
      println(data.valueArray());
    } else if (key == 's' || key == 'S') {
      poll_data = true;
    }
 }
 
 //
 void printSeparator() {
   // Always print a base amount of characters
   for (int i = 0; i < 10; i += 1) {
     print("=");
   }
   
   // Print additional amount of characters specified by line_sep_count
   for (int i = 0; i < line_sep_count; i += 1) {
     print("====");
   }
   println();
   
   // Wrap the counter around a max value
   line_sep_count = ++line_sep_count % 10;
 }
 
 // Called when the processing window is closed.
 // Close any log files and exit.
 void exit() {
   if (LOG_DATA) {
     logger.closeLogs();
     println("Log filed closed.");
   } else {
     println("No open log files to close. Exiting...");
   }
   
   // Make super call to exit()
   super.exit();
 }