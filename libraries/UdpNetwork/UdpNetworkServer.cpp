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
    this->clients = (IP_Port_Pair*) malloc(sizeof(IP_Port_Pair)*MIN_NUM_CLIENTS);
    this->responses = (IP_Port_Pair*) malloc(sizeof(IP_Port_Pair)*MIN_NUM_CLIENTS);
    for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
      clients[i].clear();
      responses[i].clear();
    }
    this->cur_num_clients = 0;
    this->cur_num_responses = 0;
}

UdpNetworkServer::~UdpNetworkServer() {
  delete clients;
  delete responses;
  clients = NULL;
  responses = NULL;
}

void UdpNetworkServer::registerClients() {
  Serial.println("Registering all clients...");
  while (cur_num_clients < MIN_NUM_CLIENTS) {
    getNewMessage();
    if (new_message.hasHeader(H_REQ_REGISTRATION)) {
      processRegistrationRequest();
    }
    delay(25);
  }
  Serial.println("Registered all clients");
  Serial.println("======================");
}

void UdpNetworkServer::processRegistrationRequest() {
  // Create handle for the client
  IP_Port_Pair current_client(Udp.remoteIP(), Udp.remotePort());
  // Send ack for registration request
  sendMessage(Udp.remoteIP(),
              Udp.remotePort(),
              MSG_ACK_REGISTRATION_REQ,
              "");
  // Add to list of registered clients if not already registered
  // This allows manual restarts of the network nodes without losing
  // the registration of the node.
  if (!registeredClient(current_client)) {
    // Add client to list of registered clients
    Serial.print("Registering new client: ");Udp.remoteIP().printTo(Serial);Serial.println();
    clients[cur_num_clients++] = current_client;
  } else {
    //Serial.print("Redundant registration request: ");Udp.remoteIP().printTo(Serial);Serial.println();
  }

}

void UdpNetworkServer::syncGroundVoltage(float voltage) {
  Serial.println("Synchronizing ground voltages...");

  // Send voltage to all clients
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    sendMessage(clients[i].getIP(),
                clients[i].getPort(),
                MSG_COMMON_GND,
                dconv.floatToBytes(voltage));
  }

  // Wait for all clients to acknowledge setting the ground voltage
  // TODO do we want a safe timeout here, or absoulutely require all clients respond here?
  //QueueList<IP_Port_Pair> client_acks;
  cur_num_responses = 0;
  while (cur_num_responses < MIN_NUM_CLIENTS) {
    getNewMessage();
    // Only listen for common ground ack messages
    if (new_message.hasHeader(H_ACK_COMMON_GND)) {
      // Verify that this client hasn't already ack'd the message
      IP_Port_Pair current_client(Udp.remoteIP(), Udp.remotePort());
      if (!clientHasResponded(current_client)) {
        Udp.remoteIP().printTo(Serial);Serial.println(" has synced to the common ground voltage.");
        responses[cur_num_responses++] = current_client;
      }
    }
  }
  Serial.print("All clients are synced to the common ground voltage ");Serial.println(voltage, 4);
  Serial.println("=========================================================");
}

void UdpNetworkServer::parseMessage() {
  if (new_message.hasHeader(H_DATA) == 0) {
    // Receive and process data
    Serial.println(dconv.bytesToFloat(new_message.getContents()));
  } else {
    Serial.println("Undefined message received!");
  }
}

void UdpNetworkServer::pollForData() {
  // Send request for data to all clients
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    sendMessage(clients[i].getIP(),
                clients[i].getPort(),
                MSG_REQ_RSS,
                "");
  }

  // Wait until all clients respond
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    responses[i].clear();
  }
  cur_num_responses = 0;

  while (cur_num_responses < MIN_NUM_CLIENTS) {
    if (hasData()) {
      if (new_message.hasHeader(H_RSS)) {
        // Verify that this client hasn't already ack'd the message
        IP_Port_Pair current_client(Udp.remoteIP(), Udp.remotePort());
        if (!clientHasResponded(current_client)) {
          Udp.remoteIP().printTo(Serial);Serial.print(" data received: ");
          Serial.println(dconv.bytesToFloat(new_message.getContents()), 4);
          responses[cur_num_responses++] = current_client;
        }
      }
    }
  }

  Serial.println("All clients have responded with data.");
  Serial.println("=====================================");

}

bool UdpNetworkServer::clientHasResponded(IP_Port_Pair client) {
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    if (client.equals(responses[i])) {
      return true;
    }
  }
  return false;
}

bool UdpNetworkServer::registeredClient(IP_Port_Pair client) {
  for (int i = 0; i < MIN_NUM_CLIENTS; ++i) {
    if (client.equals(clients[i])) {
      return true;
    }
  }
  return false;
}