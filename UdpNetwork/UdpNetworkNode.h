/*
 */

#ifndef udpnetworknode_h
#define udpnetworknode_h

#include "Arduino.h"
#include "Ethernet.h"

class UdpNetworkNode {

protected:
  // An EthernetUDP instance to let us send and receive packets over UDP
  EthernetUDP Udp;
  // Size in bytes received
  int packet_size;
  // Buffers for receiving and sending data
  char data_in[UDP_TX_PACKET_MAX_SIZE];
  // Indication of having received data
  boolean has_data;
  // Device's MAC address in int form
  unsigned int mac;
  // Device's IP address
  IPAddress my_ip;
  // Device's port number
  unsigned int my_port;

public:
  UdpNetworkNode();

  // Message constants for sending outgoing messages
  const char* MSG_ACK_REGISTRATION_REQ = "102|";
  const char* MSG_REQ_REGISTRATION = "100|";
  const char* MSG_DATA = "200|";

  // Message header constants used for decoding incoming messages
  const char* H_ACK_REGISTRATION_REQ = "102";
  const char* H_REQ_REGISTRATION = "100";
  const char* H_DATA = "200";

  // Returns the UDP handle
  EthernetUDP getUDP();
  // Sets the UDP handle
  void setUdp(EthernetUDP);
  // Returns the size (in bytes) of the currently received packet
  int getPacketSize();
  // Returns the currently received packet
  char* getDataIn();
  // Returns whether new data has arrived from another device on the network
  boolean hasData();
  // Returns the device's MAC address
  unsigned int getMac();
  // Returns the device's IP address
  IPAddress getIP();
  // Returns the device's port number
  unsigned int getPort();
  // Sets the device's port number
  void setPort(unsigned int);

  // Returns whether the received message is valid for the defined protocol
  boolean validMsg(String);
  // Returns the header code of the received message, according to the defined protocol
  String msgHeader(String);
  //  Returns the header code of the received message, according to the defined protocol
  String msgData(String);
  // Prints the size, source IP address, and source port number of the received message
  void printMsgSourceInfo();
  // Prints a human-readable format of the provided IP address
  void printIP(IPAddress);
  // Checks to see if new data has arrived from another device on the network
  void checkForData();


  

  virtual void parseMessage();


};

#endif
