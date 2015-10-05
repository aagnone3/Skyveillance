/*
 */

#include "UdpNetworkServer.h"

UdpNetworkServer::UdpNetworkServer(unsigned int mac_address,
                                   IPAddress my_ip_address,
                                   unsigned int my_port_num) {
    // Assign member variables
    this->mac = mac_address;
    this->my_ip = my_ip_address;
    this->my_port = my_port_num;
}

void UdpNetworkServer::parseMessage() {
    String msg(data_in);
    sender_ip = Udp.remoteIP();
    sender_port = Udp.remotePort();

    // Only work with valid data
    if (this->validMsg(msg)) {
       String header = msgHeader(msg);
       String data = msgData(msg);
       if (header.compareTo(H_REQ_REGISTRATION) == 0) {
           // Received a request for registering this device on the network.
           // Send an ack for the request to the device
           // TODO add device to list of known devices on network
          Serial.print("Registering new device: ");printIP(Udp.remoteIP());
          Udp.beginPacket(sender_ip, sender_port);
          Udp.write(MSG_ACK_REGISTRATION_REQ);
          Udp.endPacket();
       } else {
           Serial.println("Undefined message received!");
       }
    } else {
      Serial.println("Invalid message received!");
    } 
}
