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
    this->noise_floor = DEFAULT_NOISE_FLOOR;

    // Clients
    IPAddress client1(192, 168, 1, 1);
    IPAddress client2(192, 168, 1, 2);
    IPAddress client3(192, 168, 1, 3);
    IPAddress client4(192, 168, 1, 4);
    this->clients = new IPAddress[NUM_CLIENTS];
    this->clients[0] = client1;
    this->clients[1] = client2;
    //this->clients[2] = client3;
    //this->clients[3] = client4;

    this->responses = new IPAddress[NUM_CLIENTS];
    this->data = new float[NUM_CLIENTS];
    this->cur_num_clients = 0;

    // Flush the incoming buffer of any messages leftover from a previous run
    flush();

    // Clear any previous responses
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
  while (cur_num_clients < NUM_CLIENTS) {
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
  noise_floor = voltage;
  Serial.println("Synchronizing noise floors...");

  // Send voltage to all clients
  for (int i = 0; i < NUM_CLIENTS; ++i) {
    sendMessage(clients[i],
                8888,
                MSG_NOISE_FLOOR,
                dconv.floatToBytes(voltage));
  }

  // Wait for all clients to acknowledge setting the noise floor
  clearResponses();
  Serial.println("Listening for ACKs to the noise floor...");
  while (cur_num_responses < NUM_CLIENTS) {
	  if (hasData() && strcmp(new_message.getHeader(),H_ACK_NOISE_FLOOR) == 0) {
		  // Verify that this client hasn't already ack'd the message
		  if (!clientHasResponded(Udp.remoteIP())) {
			  Udp.remoteIP().printTo(Serial);Serial.println(" has synced to the common noise floor.");
			  responses[cur_num_responses++] = Udp.remoteIP();
		  } else {
        Serial.println("Already gotchu");
      } 
		}
  }
  Serial.print("All clients are synced to the common noise floor ");Serial.println(voltage, 4);
  Serial.println("=========================================================");
}

void UdpNetworkServer::parseMessage() {
  IPAddress sender = new_message.getSender();
  if (strcmp(new_message.getHeader(),H_RSS) == 0) {
    // Verify that this client hasn't already ack'd the message
    if (!clientHasResponded(sender)) {
      // Store the response and the data received
      responses[cur_num_responses] = sender;
      data[cur_num_responses] = dconv.bytesToFloat(new_message.getContents());
      //Udp.remoteIP().printTo(Serial);Serial.print("    ");Serial.print(dconv.bytesToFloat(new_message.getContents()));Serial.println();
      cur_num_responses += 1;
    } else {
      sender.printTo(Serial);Serial.println(" redundant response");
    }
  /*} else if (strcmp(new_message.getHeader(), H_REQ_NOISE_FLOOR) == 0) {
    // Send back the common noise floor to the client
    if (noise_floor == DEFAULT_NOISE_FLOOR) {
      Serial.println("Sending default noise floor...this is likely undesirable.");
    }
    Serial.println("Sending redundant noise floor to client: ");Udp.remoteIP().printTo(Serial);Serial.println();
    sendMessage(Udp.remoteIP(),
                8888,
                MSG_NOISE_FLOOR,
                dconv.floatToBytes(noise_floor));
    */
  } else if (strcmp(new_message.getHeader(), H_REQ_REGISTRATION) == 0) {
    Serial.println("Received new registration request.");
  } else if (strcmp(new_message.getHeader(), H_NOISE_FLOOR) == 0) {
    // Noise floor received from a client
    Udp.remoteIP().printTo(Serial);Serial.print(" noise floor: ");Serial.println(dconv.bytesToFloat(new_message.getContents()));
  } else {
    Serial.print("Undesired message received: ");
    Serial.println(new_message.getHeader());
  }
}

void UdpNetworkServer::getNewReadings() {
  flush();
  clearResponses();
  pollClients();
  collectResponses();
}

void UdpNetworkServer::pollClients() {
  // Send request for data to all clients
  //Serial.print("Polling...");
  for (int i = 0; i < NUM_CLIENTS; ++i) {
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
  // Wait until all clients respond, collecting their data as they do
  while (cur_num_responses < NUM_CLIENTS && millis() - elapsed_time < MAX_WAIT_TIME_MS) {
    if (hasData()) {
      parseMessage();
    } else {
      delay(25);
    }
  }

  // Determine whether success or a timeout has occured
  if (cur_num_responses < NUM_CLIENTS) {
    // Waited too long for clients to respond, one may have restarted.
    // Clear all responses and re-poll the clients
    Serial.println("*** Timeout! ***");
    //getNewReadings();
  } else {
    // Master adds its own voltage reading
    data[cur_num_responses] = analogRead(analog_pin) * 5.0 / 1023;
    // Log the data to the serial port for processing
    logAllReadings();
  }
}

void UdpNetworkServer::logAllReadings() {
  // Log the data to the serial port (use MATLAB/Processing for data logging)
  for (int i = 0; i < NUM_CLIENTS + 1; ++i) {
    Serial.print(data[i], 4);
    if (i < NUM_CLIENTS) Serial.print(",");
  }
  Serial.println();
  //Serial.println("===");
}

bool UdpNetworkServer::clientHasResponded(IPAddress client) {
  for (int i = 0; i < NUM_CLIENTS; ++i) {
    if (client == responses[i]) {
      return true;
    }
  }
  return false;
}

bool UdpNetworkServer::clientHasRegistered(IPAddress client) {
  for (int i = 0; i < NUM_CLIENTS; ++i) {
    if (client == clients[i]) {
      return true;
    }
  }
  return false;
}

void UdpNetworkServer::clearResponses() {
  int i;
  for (i = 0; i < NUM_CLIENTS; ++i) {
    responses[i] = INADDR_NONE;
    data[i] = 0.0;
  }
  data[i] = 0.0;
  cur_num_responses = 0;
}

void UdpNetworkServer::reportNoiseFloors() {
  // Send voltage to all clients
  for (int i = 0; i < NUM_CLIENTS; ++i) {
    sendMessage(clients[i],
                8888,
                MSG_REQ_NOISE_FLOOR,
                "");
  }
  Serial.println("Collecting noise floors...");
  
  // Announce own noise floor
  my_ip.printTo(Serial);Serial.print(" noise floor: ");Serial.println(noise_floor);

  // Wait for all clients to respond with the noise floor
  cur_num_responses = 0;
  while (cur_num_responses < NUM_CLIENTS) {
    if (hasData() && strcmp(new_message.getHeader(),H_NOISE_FLOOR) == 0) {
      // Verify that this client hasn't already ack'd the message
      if (!clientHasResponded(Udp.remoteIP())) {
        responses[cur_num_responses] = Udp.remoteIP();
        Udp.remoteIP().printTo(Serial);Serial.print(" noise floor: ");Serial.println(dconv.bytesToFloat(new_message.getContents()));
        cur_num_responses++;
      }
    }
  }
  clearResponses();
  Serial.println("===========================");
}
