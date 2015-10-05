#include <UdpNetworkClient.h>
#include <UdpNetworkNode.h>

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
#include <UdpNetworkServer.h>


// Byte array (hex) representation of the MAC address
byte mac_addr[] = { 0x90, 0xA2, 0xDA, 0x0D, 0xA6, 0xCF };
// Decimal representation of the MAC address
int mac_num = 910;
// IP address of this device
IPAddress my_ip(192, 168, 1, 111);
IPAddress dest(192, 168, 1, 222);
int port = 8888;
// Local port to listen on
unsigned int my_port_num = 8888;

EthernetUDP Udp;
UdpNetworkServer server(mac_num, my_ip, my_port_num);

void setup() {
  // Start Serial, Ethernet, Udp, and Serial modules
  Serial.begin(9600);
  Ethernet.begin(mac_addr, my_ip);
  Udp.begin(my_port_num);

  // Set the UDP handle for the server ONLY after the call to Udp.begin()
  server.setUdp(Udp);
  
  Serial.println("Server Initialized");
}

void loop() {
  // Check for incoming messages from new/current clients
  server.checkForData();

  // Process new data as it comes in
  if (server.hasData() == true) {
    server.printMsgSourceInfo();
    server.parseMessage();
  }

  delay(100);
}

