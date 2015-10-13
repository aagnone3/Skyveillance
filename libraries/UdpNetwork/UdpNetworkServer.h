/*
The UdpNetworkServer class handles all specific functionality of a network server, which
periodically polls its clients for data, and performs the triangulation algorithm
 */

#ifndef udpnetworkserver_h
#define udpnetworkserver_h

#include "UdpNetworkNode.h"
#include "IP_Port_Pair.h"
#include "QueueList.h"

class UdpNetworkServer : public UdpNetworkNode {

private:
	IP_Port_Pair* clients;
  IP_Port_Pair* responses;
  unsigned int cur_num_clients;
  unsigned int cur_num_responses;


public:
  // Constructor
  UdpNetworkServer(int,
                 unsigned int,
                 IPAddress,
                 unsigned int);
  ~UdpNetworkServer();

  //  TODO maintain list of registered client nodes
  IPAddress sender_ip;
  unsigned int sender_port;
  const int MIN_NUM_CLIENTS = 2;

  // Register all clients in the network
  void registerClients();
  // Process a registration request from a client
  void processRegistrationRequest();
  // Send a synchronized ground voltage to all clients
  void syncGroundVoltage(float);
  // Parse an incoming message from a client
  void parseMessage();
  // Poll through all clients for data readings
  void pollForData();
  //
  bool clientHasResponded(IP_Port_Pair);
  //
  bool registeredClient(IP_Port_Pair);
};

#endif
