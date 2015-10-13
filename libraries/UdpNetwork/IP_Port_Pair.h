/*
The IP_Port_Pair class is a light-weight rendition of a client. It is used by a node
to have knowledge of the IP address and port number of a client to send/receive a message
to/from, without any superfluous details.
 */

#ifndef ip_port_pair_h
#define ip_port_pair_h

#include "Arduino.h"
#include "Ethernet.h"

class IP_Port_Pair {

private:
	// Port number of the device
	unsigned int port;
	// IP address of the device
	IPAddress ip;

public:
  // Constructor
  IP_Port_Pair();
  IP_Port_Pair(IPAddress,unsigned int);

  // Set the port number
  void setPort(unsigned int);
  // Return the port number
  unsigned int getPort() const;
  // Set the IP address
  void setIP(IPAddress);
  // Return the IP address
  IPAddress getIP() const;
  // Determine equality of other IP_Port_Pair
  bool equals(IP_Port_Pair);
  // Clear data
  void clear();

};

#endif
