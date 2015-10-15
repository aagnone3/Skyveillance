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
  if (strcmp(new_message.getHeader(),H_COMMON_GND) == 0) {
	  Serial.println("Ground ack message rcvd");
    // Set a synchronized ground voltage for measurement accuracy
    setGroundVoltage(dconv.bytesToFloat(new_message.getContents()));
    // Acknowledge that the received ground voltage has been set
    sendMessage(master_ip,
                master_port,
                MSG_ACK_COMMON_GND,
                "");
    Serial.print("ACK'd and set ground voltage to ");Serial.println(ground_voltage, 4);
  } else if (strcmp(new_message.getHeader(),H_REQ_RSS) == 0) {
    // Send current reading to the master
    //float reading = analogRead(analog_pin) * 5.0 / 1023;
    sendMessage(master_ip,
                master_port,
                MSG_RSS,
                dconv.floatToBytes(analogRead(analog_pin) * 5.0 / 1023));
    Serial.println("Sent reading.");//Serial.print(reading, 4);Serial.println(" to master.");
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
    if (hasData() && strcmp(new_message.getHeader(), H_ACK_REGISTRATION_REQ) == 0) {
         // Received an acknowledge for registering this device with the network's master device.
         if (!is_registered) {
             Serial.println("Successfully registered with the master node");
             is_registered = true;
         } else {
             Serial.println("Received redundant registration ack from the master node");
         }
    } else {
      // Send another req to the master device
      Serial.println("Sending registration request to the master node.");
      sendMessage(master_ip,
                  master_port,
                  MSG_REQ_REGISTRATION,
                  "");
      delay(250);
    }
  }
}