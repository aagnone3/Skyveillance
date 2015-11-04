 //
 import hypermedia.net.*;
 
 // Number of clients
 final int NUM_CLIENTS = 3;
 // Port number to send to for all clients
 final int DEST_PORT_NUM = 8888;
 // Timeout in ms for waiting for client responses to setting the noise floor
 final int NOISE_FLOOR_TIMEOUT_MS = 10000;
 // Timeout in ms for waiting for client responses for data
 final int DATA_TIMEOUT_MS = 3000;
 // Flag to indicate whether or not we want to log data
 final boolean LOG_DATA = true;
 
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


 void setup() {
   size(300, 200);
   
   udp = new UDP( this, 6000 );  // create a new datagram connection on port 6000
   //udp.log( true );     // <-- printout the connection activity
   udp.listen( true );           // and wait for incoming message
   
   rcvd = new ArrayList<String>();
   ips = new ArrayList<String>();
   ips.add("192.168.1.1");
   ips.add("192.168.1.2");
   ips.add("192.168.1.3");
   
   got_all_responses = false;
   line_sep_count = 0;
   
   data = new FloatDict();
   for (int i = 0; i < NUM_CLIENTS; i += 1) {
     data.set(ips.get(i), -999.0);
   }
   
   logger = new DataLogger(LOG_DATA);
   initDisplay(LOG_DATA);
 }

 // Do nothing automatically. Behavior is triggered via key presses.
 // See keyPressed() for more details.
 void draw() {}
 
 // Called only when 's' or 'S' key entered
 void loop() {
   
   // Remain in an infinite loop, with only interrupt functions to alter code flow
   while (true) {
     printSeparator();

     // Poll all clients for data values
     sendRequestsForData();
     
     // Only perform data operations if all client responses were successfully received
     if (dataSuccessfullyCollected(DATA_TIMEOUT_MS)) {
       // Convert pin voltages to distances
       double[] distances = toDistances(data.valueArray());
       // Triangulation
       
       // Log all data for this iteration
       logger.logData("Everything", data, distances, 0.0);
     }
     // Else re-poll for data
  
     delay(2000);
   }
 }
 
 void sendRequestsForData() {
   // Clear list of ip's we have received data from
   rcvd.clear();
    
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
       println("Timeout!");
       return false;
     }
     delay(20);
   }
   
   // Return true to indicate that all data was successfully received
   return true;
 }

 void receive(byte[] rcvd_data, String ip, int port) {
   if (rcvd_data.length == 10 && !rcvd.contains(ip)) {
     // Add ip to the received list
     rcvd.add(ip);
     float reading = bytesToFloat(rcvd_data, 4);
     data.set(ip, reading);
       
     // Check to see if we have data from all clients
     if (rcvd.size() == NUM_CLIENTS) {
       got_all_responses = true;
       println(data.valueArray());
     }
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
      println("Noise floors set!");
    } else if (key == 's' || key == 'S') {
      loop();
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