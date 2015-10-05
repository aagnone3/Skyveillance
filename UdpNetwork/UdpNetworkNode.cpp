/*
 */

#include "UdpNetworkNode.h"

UdpNetworkNode::UdpNetworkNode() {}

EthernetUDP UdpNetworkNode::getUDP() {
  return Udp;
}

void UdpNetworkNode::setUdp(EthernetUDP udp) {
  this->Udp = udp;
}

int UdpNetworkNode::getPacketSize() {
  return packet_size;
}

char* UdpNetworkNode::getDataIn() {
  return data_in;
}

boolean UdpNetworkNode::hasData() {
  return has_data;
}

unsigned int UdpNetworkNode::getMac() {
  return mac;
}

IPAddress UdpNetworkNode::getIP() {
  return my_ip;
}

unsigned int UdpNetworkNode::getPort() {
  return my_port;
}

void UdpNetworkNode::setPort(unsigned int port) {
  this->my_port = port;
}


boolean UdpNetworkNode::validMsg(String msg) {
    return msg.indexOf("|") != -1;
}

String UdpNetworkNode::msgHeader(String msg) {
    int pos = msg.indexOf("|");
    return msg.substring(0, pos);
}

String UdpNetworkNode::msgData(String msg) {
    int pos = msg.indexOf("|");
    if (pos > -1 && pos < msg.length() - 1) {
        return msg.substring(0, pos);
    }
    return "n/a";
}

void UdpNetworkNode::printMsgSourceInfo() {
    Serial.print("-- Received packet of size ");
    Serial.print(packet_size);
    Serial.print(" from ");
    printIP(Udp.remoteIP());
    Serial.print(", port ");
    Serial.println(Udp.remotePort());  
}

void UdpNetworkNode::printIP(IPAddress ip) {
    for (int i = 0; i < 4; i++)
    {
      Serial.print(ip[i], DEC);
      if (i < 3)
      {
        Serial.print(".");
      }
    }
}

void UdpNetworkNode::checkForData() {
    packet_size = Udp.parsePacket();
    if (packet_size) {
        has_data = true;

        // Parse the packet
        Udp.read(data_in, UDP_TX_PACKET_MAX_SIZE);
    } else {
      has_data = false;
    }

}

void UdpNetworkNode::parseMessage() {}