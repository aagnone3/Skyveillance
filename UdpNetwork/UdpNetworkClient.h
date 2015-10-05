/*
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

public:
  // Constructor
  UdpNetworkClient(unsigned int,
                 IPAddress,
                 IPAddress,
                 unsigned int,
                 unsigned int);

  // Process the currently received message
  void parseMessage();
  // Send a registration request message to the master device
  void sendRegistrationReqMsg();
  // Register the device in the network by sending a registration request message
  //   to the network's master device until an acknowledge message is received 
  void registerWithNetwork();

};

#endif
