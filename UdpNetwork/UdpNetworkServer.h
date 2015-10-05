/*
 */

#ifndef udpnetworkserver_h
#define udpnetworkserver_h

#include "UdpNetworkNode.h"

class UdpNetworkServer : public UdpNetworkNode {

private:


public:
  // Constructor
  UdpNetworkServer(unsigned int,
                 IPAddress,
                 unsigned int);

  //  TODO maintain list of registered client nodes
  IPAddress sender_ip;
  unsigned int sender_port;

  void parseMessage();

};

#endif
