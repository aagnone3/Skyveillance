/*
 */

#include "UdpNetworkClient.h"

UdpNetworkClient::UdpNetworkClient(unsigned int mac_address,
                                   IPAddress my_ip_address,
                                   IPAddress master_ip_address,
                                   unsigned int my_port_num,
                                   unsigned int master_port_num) {
    // Assign member variables
    this->mac = mac_address;
    this->my_ip = my_ip_address;
    this->master_ip = master_ip_address;
    this->my_port = my_port_num;
    this->master_port = master_port_num;

    // Begin UDP module
    Udp.begin(my_port);
}

void UdpNetworkClient::parseMessage() {
    String msg(data_in);

    // Only work with valid data
    if (validMsg(msg)) {
       String header = msgHeader(msg);
       String data = msgData(msg);
       //Serial.print("Header: ");Serial.println(header);
       //Serial.print("Data: ");Serial.println(data);
       /*
       if (header.compareTo(H_ACK_REGISTRATION_REQ) == 0) {
       } else {
           Serial.println("Undefined message received!");
       }
       */
    } else {
      Serial.println("Invalid message received!");
    } 
}

void UdpNetworkClient::sendRegistrationReqMsg() {
    // Send registration message to the master node
    Udp.beginPacket(master_ip, master_port);
    Udp.write(MSG_REQ_REGISTRATION);
    Udp.endPacket();
}

void UdpNetworkClient::registerWithNetwork() {
  // Loop until we have successfully registered with the network's master device
  while (!is_registered) {
      // Check for incoming data
      int packetSize = Udp.parsePacket();
      if (packetSize) { 
          // Parse the packet
          Udp.read(data_in, UDP_TX_PACKET_MAX_SIZE);
          parseMessage();
    
          //String header = msgHeader(data_in);
          if (msgHeader(data_in).compareTo(H_ACK_REGISTRATION_REQ) == 0) {
               // Received an acknowledge for registering this device with the network's master device.
               if (!is_registered) {
                   Serial.println("Successfully registered with the master node");
                   is_registered = true;
               } else {
                   Serial.println("Received redundant registration ack from the master node");
               }
          } else {
              // Send another ack to the master device
              Serial.println("Attempting to register with the network's master device");
              sendRegistrationReqMsg();
          }
      } else {
          // Send another ack to the master device
          Serial.println("Attempting to register with the network's master device");
          sendRegistrationReqMsg();
      }
      delay(100);
  }
}
