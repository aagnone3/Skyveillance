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
    this->ground_voltage = DEFAULT_GROUND_VOLTAGE;
    this->is_registered = false;
    this->num_readings = 0;
}

void UdpNetworkClient::parseMessage() {

  if (strcmp(new_message.getHeader(),H_COMMON_GND) == 0) {

	  Serial.println("Ground ack message rcvd");
    // Set a synchronized ground voltage for measurement accuracy
    ground_voltage = dconv.bytesToFloat(new_message.getContents());
    // Acknowledge that the received ground voltage has been set
    sendMessage(master_ip,
                master_port,
                MSG_ACK_COMMON_GND,
                "");
    // Write out the ground voltage to the antenna
    analogWrite(9, ground_voltage;
    Serial.print("ACK'd and set ground voltage to ");Serial.println(ground_voltage, 4);

  } else if (strcmp(new_message.getHeader(),H_REQ_RSS) == 0) {

    if (ground_voltage == DEFAULT_GROUND_VOLTAGE) {
      // Client has not received the ground voltage, request it from the master
      Serial.println("Don't have the ground voltage, requesting it from the master...");
      sendMessage(master_ip,
                  master_port,
                  MSG_REQ_COMMON_GND,
                  "");
    } else {
      // Send current reading to the master
      //float reading = analogRead(analog_pin) * 5.0 / 1023;
      delay(50);
      sendMessage(master_ip,
                  master_port,
                  MSG_RSS,
                  dconv.floatToBytes(max_reading));
      Serial.print("Sent max from ");Serial.print(num_readings);Serial.println(" readings.");
      num_readings = 0;
    }

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

void UdpNetworkClient::takeReading() {
  float current_reading = analogRead(analog_pin) * 5.0 / 1023;
  ++num_readings;
  if (current_reading > max_reading) {
    max_reading = current_reading;
  }

  // give time for the ADC to settle before next reading
  delay(2);
}