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

float UdpNetworkNode::getNoiseFloor() {
  return noise_floor;
}

void UdpNetworkNode::acquireNoiseFloor() {
  //Serial.print("Sampling for noise floor...");
  for (int i = 0; i < 5000; i += 1) {
    float sample = analogRead(analog_pin) * 5.0 / 1023;
    // Compute a continuous average without allocating memory for all the data points
    noise_floor = (noise_floor * i + sample) / (i + 1);
  }
  // Write out the noise floor to the antenna
  analogWrite(9, noise_floor);
  Serial.println(noise_floor);
}

void UdpNetworkNode::setNoiseFloor(float noise_floor) {
  this->noise_floor = noise_floor;
}

/*
boolean UdpNetworkNode::isValidMsg(Message msg) {
    return msg.getContents().indexOf("|") != -1;
}
*/

String UdpNetworkNode::msgHeader(String msg) {
    int pos = msg.indexOf("|");
    return msg.substring(0, pos);
}

String UdpNetworkNode::msgData(String msg) {
    int pos = msg.indexOf("|");
    if (pos > -1 && pos < msg.length() - 1) {
        return msg.substring(pos+1);
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
    Serial.println();
}

bool UdpNetworkNode::hasData() {
  getNewMessage();
  return has_data;
}

void UdpNetworkNode::getNewMessage() {
  has_data = false;
  packet_size = Udp.parsePacket();
  if (packet_size) {
    Udp.read(data_in, UDP_TX_PACKET_MAX_SIZE);
    new_message.parse(data_in, packet_size, Udp.remoteIP());
    has_data = new_message.isValid();
  }
}

void UdpNetworkNode::sendMessage(IPAddress ip, unsigned int port, const char* header, const char* contents) {
  Udp.beginPacket(ip, port);
  Udp.write(header);
  Udp.write(contents);
  Udp.endPacket();
}

void UdpNetworkNode::parseMessage() {}

void UdpNetworkNode::flush() {
  // Dump all pending messages to flush the incoming buffer
  while(hasData());
}