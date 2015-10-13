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
#include <UdpNetworkClient.h>

// Byte array (hex) representation of the MAC address
byte mac_addr[] = { 0x90, 0xA2, 0xDA, 0x0D, 0xA7, 0x30 }; // DL
// Decimal representation of the MAC address
int mac_num = 42800; // 16 LSBs
// IP address of this device
IPAddress my_ip(192, 168, 1, 3);
// IP address of the networked master device
IPAddress master_ip(192, 168, 1, 111);
// Ports to listen on and send to
unsigned int my_port_num = 8888,
             master_port_num = 8888;
             
// EthernetUDP instance to handle sending and receiving packets over UDP
EthernetUDP Udp;
// UdpNetworkClient instance to handle network comm between the client and server
UdpNetworkClient client(A0, mac_num, my_ip, master_ip, my_port_num, master_port_num);

void setup() {
  // Start Serial, Ethernet, Udp, and Serial modules
  Serial.begin(9600);
  Ethernet.begin(mac_addr, my_ip);
  Udp.begin(my_port_num);

  // Set the UDP handle for the server ONLY after the call to Udp.begin()
  client.setUdp(Udp);
  
  // Register with the network's master node before proceeding to loop()
  client.registerWithNetwork();
}

void loop() {

  // Process new data as it comes in
  // This is a passive, light-weight client. It only sends data to the master when the master tells it to.
  if (client.hasData()) {
    client.parseMessage();
  }

  // Delay to avoid spamming the network
  delay(100);
}
