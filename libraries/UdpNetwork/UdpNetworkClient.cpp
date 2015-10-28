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
    this->noise_floor = DEFAULT_NOISE_FLOOR;
    this->is_registered = false;
    this->num_readings = 0;

    // Flush the incoming buffer of any messages leftover from a previous run
    flush();
}

void UdpNetworkClient::parseMessage() {

  if (strcmp(new_message.getHeader(),H_REQ_NOISE_FLOOR) == 0) {

	  Serial.println("Noise floor request message rcvd");
    // Send back the current noise floor
    sendMessage(master_ip,
                master_port,
                MSG_NOISE_FLOOR,
                dconv.floatToBytes(noise_floor));
    Serial.print("Reported noise floor: ");Serial.println(noise_floor, 4);

  } else if (strcmp(new_message.getHeader(),H_REQ_RSS) == 0) {

    // Send current reading to the master
    //float reading = analogRead(analog_pin) * 5.0 / 1023;
    //delay(50);
    sendMessage(master_ip,
                master_port,
                MSG_RSS,
                dconv.floatToBytes(max_reading));
    Serial.print(num_readings);Serial.print("-reading max: ");Serial.print(max_reading, 4);Serial.println(" [V]");
    num_readings = 0;

  } else {
    //Serial.println(new_message.getHeader());
    //Serial.print("should be ");Serial.println(H_NOISE_FLOOR);
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
