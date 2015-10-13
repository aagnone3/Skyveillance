/*
 */

#include "UdpNetworkClient.h"

UdpNetworkClient::UdpNetworkClient(int analog_in,
                                   unsigned int mac_address,
                                   IPAddress my_ip_address,
                                   IPAddress master_ip_address,
                                   unsigned int my_port_num,
                                   unsigned int master_port_num) {
    // Assign member variables
    this->analog_pin = analog_in;
    this->mac = mac_address;
    this->my_ip = my_ip_address;
    this->master_ip = master_ip_address;
    this->my_port = my_port_num;
    this->master_port = master_port_num;
    this->ground_voltage = 0.0;
    this->is_registered = false;
}

void UdpNetworkClient::parseMessage() {
  if (new_message.hasHeader(H_COMMON_GND)) {
    // Set a synchronized ground voltage for measurement accuracy
    setGroundVoltage(dconv.bytesToFloat(new_message.getContents()));
    // Acknowledge that the received ground voltage has been set
    sendMessage(master_ip,
                master_port,
                MSG_ACK_COMMON_GND,
                "");
    Serial.print("Set ground voltage to ");Serial.println(ground_voltage, 4);
  } else if (new_message.hasHeader(H_REQ_RSS)) {
    // Send current reading to the master
    sendMessage(master_ip,
                master_port,
                MSG_RSS,
                dconv.floatToBytes(analogRead(analog_pin) * 5.0 / 1023));
  } else {
    //Serial.println(new_message.getHeader());
    //Serial.print("should be ");Serial.println(H_COMMON_GND);
    //Serial.println("Invalid message received!");
  }
}

void UdpNetworkClient::registerWithNetwork() {
  // Loop until we have successfully registered with the network's master device
  while (!is_registered) {
      // Check for incoming data
      int packetSize = Udp.parsePacket();
      if (packetSize) { 
          // Parse the packet
          Udp.read(data_in, UDP_TX_PACKET_MAX_SIZE);
    
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
              sendMessage(master_ip,
                          master_port,
                          MSG_REQ_REGISTRATION,
                          "");
          }
      } else {
          // Send another ack to the master device
          Serial.println("Attempting to register with the network's master device");
          sendMessage(master_ip,
                      master_port,
                      MSG_REQ_REGISTRATION,
                      "");
      }
      delay(100);
  }
}