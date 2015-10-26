/*
The UdpNetworkNode class is the base class for the UdpNetworkServer and UdpNetworkClient
classes. This class defines all the basic functaionality that is shared between the two,
such as IP/Port identification and general message handling.
 */

#ifndef udpnetworknode_h
#define udpnetworknode_h

#include "Arduino.h"
#include "SD.h"
#include "Ethernet.h"
#include "Message.h"
#include "Protocol.h"
#include "DataConverter.h"
#include "MemoryFree.h"

class UdpNetworkNode {

protected:
  // An EthernetUDP instance to let us send and receive packets over UDP
  EthernetUDP Udp;
  // Size in bytes received
  int packet_size;
  // Buffer for receiving data
  char data_in[UDP_TX_PACKET_MAX_SIZE];
  // Handle for decoded messages
  Message new_message;
  // Indication of having received data
  boolean has_data;
  // Device's MAC address in int form
  unsigned int mac;
  // Device's IP address
  IPAddress my_ip;
  // Device's port number
  unsigned int my_port;
  // Device's ground voltage to use
  float ground_voltage;
  // Default ground voltage
  float DEFAULT_GROUND_VOLTAGE;
  // Data Management handle
  DataConverter dconv;
  // Analog pin for making measurements
  int analog_pin;
  // Time used for measuring differences in time
  unsigned long elapsed_time;

public:
  UdpNetworkNode();

  // Returns the UDP handle
  EthernetUDP getUDP();
  // Sets the UDP handle
  void setUdp(EthernetUDP);
  // Returns the size (in bytes) of the currently received packet
  int getPacketSize();
  // Returns the currently received packet
  char* getDataIn();
  // Returns the device's MAC address
  unsigned int getMac();
  // Returns the device's IP address
  IPAddress getIP();
  // Returns the device's port number
  unsigned int getPort();
  // Sets the device's port number
  void setPort(unsigned int);
  // Return the ground voltage
  float getGroundVoltage();
  // Sets the ground voltage
  void setGroundVoltage(float);

  // Returns whether the received message is valid for the defined protocol
  //boolean isValidMsg(Message);
  // Returns the header code of the received message, according to the defined protocol
  String msgHeader(String);
  //  Returns the header code of the received message, according to the defined protocol
  String msgData(String);
  // Prints the size, source IP address, and source port number of the received message
  void printMsgSourceInfo();
  // Prints a human-readable format of the provided IP address
  void printIP(IPAddress);
  // Returns whether new data has arrived from another device on the network
  // If new valid data has arrived, the data is decoded into a Message handle
  boolean hasData();
  // Check for an incoming message, and set a handle on the decoded message if one is present
  void getNewMessage();
  // Send a message to a specified client, or broadcast to all
  void sendMessage(IPAddress, unsigned int, const char*, const char*);
  // Virtual function to parse messages that is implemented by subclassses
  virtual void parseMessage();


};

#endif
