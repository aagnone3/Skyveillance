/*
  UDPSendReceive.pde:
 This sketch receives UDP message strings, prints them to the serial port
 and sends an "acknowledge" string back to the sender

 A Processing sketch is included at the end of file that can be used to send
 and received messages for testing with a computer.

 created 21 Aug 2010
 by Michael Margolis

 modified 5 December 2015
 by Anthony Agnone

 This code is in the public domain.
 */

// Include SPI library for Arduino versions later than 0018
#include <SPI.h>
#include <Ethernet.h>
#include <String.h>
#include <UdpNetworkClient.h>
#include <UdpNetworkServer.h>


// Byte array (hex) representation of the MAC address
byte mac_addr[] = { 0x90, 0xA2, 0xDA, 0x0D, 0xA6, 0xCF };
// Decimal representation of the MAC address
int mac_num = 42703; // 16 LSBs
// IP address of this device
IPAddress my_ip(192, 168, 1, 111);
int port = 8888;
// Local port to listen on
unsigned int my_port_num = 8888;

EthernetUDP Udp;
UdpNetworkServer server(A0, mac_num, my_ip, my_port_num);

void setup() {
  // Start Serial, Ethernet, Udp, and Serial modules
  Serial.begin(9600);
  Ethernet.begin(mac_addr, my_ip);
  Udp.begin(my_port_num);

  // Set the UDP handle for the server ONLY after the call to Udp.begin()
  server.setUdp(Udp);

  // Register all clients before proceeding
  // TODO verify NUM_CLIENTS is correct before running
  server.registerClients();
  delay(250);

  // Send a synchronized ground voltage to all clients
  server.syncGroundVoltage(0.147); // TODO dynamically determine this voltage
  
  Serial.println("Server initialization complete");
  Serial.println("==============================");
}

void loop() {
  /*
  // Process new data as it comes in
  if (server.hasData()) {
    server.parseMessage();
  }
  */

  // Periodically poll clients for their readings
  server.pollForData();
  // Perform triangulation

  // Delay to avoid spamming the network
  delay(100);
}

