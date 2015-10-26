/*
The UdpNetworkClient class handles all specific functionality of a network client, which
simply registers with a master node and reports data to it as requested
 */

#ifndef udpnetworkclient_h
#define udpnetworkclient_h

#include "UdpNetworkNode.h"

class UdpNetworkClient : public UdpNetworkNode {

private:
	// Maintain registration status with the master node
	boolean is_registered;
	// IP address of the networked master device
	IPAddress master_ip;
	// Port number of the networked master device
  unsigned int master_port;
  // Current max of readings
  float max_reading;
  // Number of readings in current window
  unsigned int num_readings;

public:
  // Constructor
  UdpNetworkClient(int,
                 unsigned int,
                 IPAddress,
                 IPAddress,
                 unsigned int,
                 unsigned int);

  // Process the currently received message
  void parseMessage();
  // Register the device in the network by sending a registration request message
  // to the network's master device until an acknowledge message is received 
  void registerWithNetwork();
  // Take a new voltage reading
  void takeReading();
};

#endif
