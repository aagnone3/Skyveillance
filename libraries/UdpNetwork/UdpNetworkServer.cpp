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
    this->ground_voltage = 0.0;
    this->clients = (IPAddress*) malloc(sizeof(IPAddress) * MIN_NUM_CLIENTS);
    this->responses = (IPAddress*) malloc(sizeof(IPAddress) * MIN_NUM_CLIENTS);
    this->data = (float*) malloc(sizeof(float) * (MIN_NUM_CLIENTS + 1));
    this->cur_num_clients = 0;
    clearResponses();
}

UdpNetworkServer::~UdpNetworkServer() {
  delete clients;
  delete responses;
  delete data;
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
  int cur_num_responses = 0;
  Serial.println("Listening for ACKs to the ground voltage...");
  while (cur_num_responses < MIN_NUM_CLIENTS) {
	  if (hasData()) {
			// Only listen for common ground ack messages
			//Serial.println(new_message.getHeader());
			if (strcmp(new_message.getHeader(),H_ACK_COMMON_GND) == 0) {
			  // Verify that this client hasn't already ack'd the message
			  if (!clientHasResponded(Udp.remoteIP())) {
				  Udp.remoteIP().printTo(Serial);Serial.println(" has synced to the common ground voltage.");
				  responses[cur_num_responses++] = Udp.remoteIP();
			  } else {
          Serial.println("Already gotchu");
        }
			}	  
		}
  }
  Serial.print("All clients are synced to the common ground voltage ");Serial.println(voltage, 4);
  Serial.println("=========================================================");
}

void UdpNetworkServer::parseMessage() {
  if (strcmp(new_message.getHeader(),H_DATA) == 0) {
    // Receive and process data
    Serial.println(dconv.bytesToFloat(new_message.getContents()));
  } else {
    Serial.println("Undefined message received!");
  }
}

void UdpNetworkServer::pollForData() {
  // Send request for data to all clients
  Serial.print("Polling...");
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    sendMessage(clients[i],
                8888,
                MSG_REQ_RSS,
                "");
  }
  Serial.println("Waiting...");

  clearResponses();
  int cur_num_responses = 0;
  // Wait until all clients respond, collecting their data as they do
  while (cur_num_responses < MIN_NUM_CLIENTS) {
    if (hasData() && strcmp(new_message.getHeader(),H_RSS) == 0) {
        // Verify that this client hasn't already ack'd the message
        if (!clientHasResponded(Udp.remoteIP())) {
		      // Store the response and the data received
          responses[cur_num_responses] = Udp.remoteIP();
		      data[cur_num_responses] = dconv.bytesToFloat(new_message.getContents());
          //Udp.remoteIP().printTo(Serial);
          //Serial.print(cur_num_responses+1);Serial.print("/");Serial.println(MIN_NUM_CLIENTS);
          //Serial.println("Data received: ");
          //Serial.println(data[cur_num_responses], 4);
          ++cur_num_responses;
        }
    } else {
        delay(25);
    }
  }
  // Master adds its own voltage reading
  data[cur_num_responses] = analogRead(analog_pin) * 5.0 / 1023;

  // Log the data to the serial port (use MATLAB for data logging)
  for (int i = 0; i < MIN_NUM_CLIENTS + 1; ++i) {
    Serial.print(data[i], 4);
    if (i < MIN_NUM_CLIENTS) Serial.print(",");
  }
  Serial.println();
  Serial.println("=====================================");

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
