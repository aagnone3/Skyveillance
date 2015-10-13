/*
 */

#include "IP_Port_Pair.h"

  IP_Port_Pair::IP_Port_Pair() {
  }

  IP_Port_Pair::IP_Port_Pair(IPAddress ip, unsigned int port) {
    this->ip = ip;
    this->port = port;
  }

  void IP_Port_Pair::setPort(unsigned int port) {
    this->port = port;
  }

  unsigned int IP_Port_Pair::getPort() const {
    return port;
  }

  void IP_Port_Pair::setIP(IPAddress ip) {
    this->ip = ip;
  }

  IPAddress IP_Port_Pair::getIP() const {
    return ip;
  }

  bool IP_Port_Pair::equals(IP_Port_Pair rhs) {
    return (this->ip == rhs.getIP() && this->port == rhs.getPort());
  }

  void IP_Port_Pair::clear() {
    IPAddress newip(0,0,0,0);
    ip = newip;
    port = 0;
  }
