/*
 */

#include "UdpNetworkServer.h"

UdpNetworkServer::UdpNetworkServer(int analog_pin,
                                   unsigned int mac_address,
                                   IPAddress my_ip_address,
                                   unsigned int my_port_num) {
    // Assign member variables
    this->analog_pin = analog_pin;
    this->mac = mac_address;
    this->my_ip = my_ip_address;
    this->my_port = my_port_num;
    this->ground_voltage = DEFAULT_GROUND_VOLTAGE;

    // Clients
    IPAddress client1(192, 168, 1, 1);
    IPAddress client2(192, 168, 1, 2);
    IPAddress client3(192, 168, 1, 3);
    IPAddress client4(192, 168, 1, 4);
    this->clients = new IPAddress[MIN_NUM_CLIENTS];
    this->clients[0] = client1;
    this->clients[1] = client2;
    //this->clients[2] = client3;
    //this->clients[3] = client4;

    this->responses = new IPAddress[MIN_NUM_CLIENTS];
    this->data = new float[MIN_NUM_CLIENTS];
    this->cur_num_clients = 0;
    this->cur_num_responses = 0;
    clearResponses();
}

UdpNetworkServer::~UdpNetworkServer() {
  delete[] clients;
  delete[] responses;
  delete[] data;
  clients = NULL;
  responses = NULL;
  data = NULL;
}

void UdpNetworkServer::registerClients() {
  for (int i = 0; i < 10; ++i) Serial.println("=============================");
  Serial.println("Registering all clients...");
  while (cur_num_clients < MIN_NUM_CLIENTS) {
    if (hasData()) {
      if (strcmp(new_message.getHeader(),H_REQ_REGISTRATION) == 0) {
        processRegistrationRequest();
      }
    }
    delay(25);
  }
  Serial.println("Registered all clients");
  Serial.println("======================");
}

void UdpNetworkServer::processRegistrationRequest() {
  // Send ack for registration request
  sendMessage(Udp.remoteIP(),
              Udp.remotePort(),
              MSG_ACK_REGISTRATION_REQ,
              "");
  // Add to list of registered clients if not already registered
  // This allows manual restarts of the network nodes without losing
  // the registration of the node.
  if (!clientHasRegistered(Udp.remoteIP())) {
    // Add client to list of registered clients
    Serial.print("Registering new client: ");Udp.remoteIP().printTo(Serial);Serial.println();
    clients[cur_num_clients++] = Udp.remoteIP();
  } else {
    //Serial.print("Redundant registration request: ");Udp.remoteIP().printTo(Serial);Serial.println();
  }

}

void UdpNetworkServer::syncGroundVoltage(float voltage) {
  ground_voltage = voltage;
  Serial.println("Synchronizing ground voltages...");

  // Send voltage to all clients
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    sendMessage(clients[i],
                8888,
                MSG_COMMON_GND,
                dconv.floatToBytes(voltage));
  }

  // Wait for all clients to acknowledge setting the ground voltage
  clearResponses();
  cur_num_responses = 0;
  Serial.println("Listening for ACKs to the ground voltage...");
  while (cur_num_responses < MIN_NUM_CLIENTS) {
	  if (hasData() && strcmp(new_message.getHeader(),H_ACK_COMMON_GND) == 0) {
		  // Verify that this client hasn't already ack'd the message
		  if (!clientHasResponded(Udp.remoteIP())) {
			  Udp.remoteIP().printTo(Serial);Serial.println(" has synced to the common ground voltage.");
			  responses[cur_num_responses++] = Udp.remoteIP();
		  } else {
        Serial.println("Already gotchu");
      } 
		}
  }
  Serial.print("All clients are synced to the common ground voltage ");Serial.println(voltage, 4);
  Serial.println("=========================================================");
}

void UdpNetworkServer::parseMessage() {
  if (strcmp(new_message.getHeader(),H_RSS) == 0) {
    // Verify that this client hasn't already ack'd the message
    if (!clientHasResponded(Udp.remoteIP())) {
      // Store the response and the data received
      responses[cur_num_responses] = Udp.remoteIP();
      data[cur_num_responses] = dconv.bytesToFloat(new_message.getContents());
      //Udp.remoteIP().printTo(Serial);Serial.println();
      //Serial.print(cur_num_responses+1);Serial.print("/");Serial.println(MIN_NUM_CLIENTS);
      ++cur_num_responses;
    }
  } else if (strcmp(new_message.getHeader(), H_REQ_COMMON_GND) == 0) {
    // Send back the common ground voltage to the client
    if (ground_voltage == DEFAULT_GROUND_VOLTAGE) {
      Serial.println("Sending default ground voltage...this is likely undesirable.");
    }
    Serial.println("Sending redundant ground voltage to client: ");Udp.remoteIP().printTo(Serial);Serial.println();
    sendMessage(Udp.remoteIP(),
                8888,
                MSG_COMMON_GND,
                dconv.floatToBytes(ground_voltage));
  } else if (strcmp(new_message.getHeader(), H_REQ_REGISTRATION) == 0) {
    Serial.println("Received new registration request.");
  } else {
    Serial.print("Undesired message received: ");
    Serial.println(new_message.getHeader());
  }
}

void UdpNetworkServer::getNewReadings() {
  pollClients();
  collectResponses();
  logAllReadings();
}

void UdpNetworkServer::pollClients() {
  // Send request for data to all clients
  //Serial.print("Polling...");
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    sendMessage(clients[i],
                8888,
                MSG_REQ_RSS,
                "");
  }
  // Reset the elapsed time counter for receiving message from clients
  elapsed_time = millis();

  //Serial.println("Waiting...");
}

void UdpNetworkServer::collectResponses() {
  clearResponses();
  cur_num_responses = 0;
  // Wait until all clients respond, collecting their data as they do
  while (cur_num_responses < MIN_NUM_CLIENTS) {
    if (hasData()) {
      parseMessage();
    } else if (millis() - elapsed_time < MAX_WAIT_TIME_MS) {
      delay(25);
    } else {
      // Waited too long for clients to respond, one may have restarted.
      // Clear all responses and re-poll the clients
      Serial.println("*** Timeout! ***");
      clearResponses();
      pollClients();
    }
  }
  // Master adds its own voltage reading
  data[cur_num_responses] = analogRead(analog_pin) * 5.0 / 1023;
}

void UdpNetworkServer::logAllReadings() {
  // Log the data to the serial port (use MATLAB for data logging)
  for (int i = 0; i < MIN_NUM_CLIENTS + 1; ++i) {
    Serial.print(data[i], 4);
    if (i < MIN_NUM_CLIENTS) Serial.print(",");
  }
  Serial.println();
  //Serial.println("===");
}

bool UdpNetworkServer::clientHasResponded(IPAddress client) {
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    if (client == responses[i]) {
      return true;
    }
  }
  return false;
}

bool UdpNetworkServer::clientHasRegistered(IPAddress client) {
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    if (client == clients[i]) {
      return true;
    }
  }
  return false;
}

void UdpNetworkServer::clearResponses() {
  int i;
  for (i = 0; i < MIN_NUM_CLIENTS; ++i) {
    responses[i] = INADDR_NONE;
    data[i] = 0.0;
  }
  data[i] = 0.0;
}
