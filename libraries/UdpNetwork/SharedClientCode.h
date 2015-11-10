
#include <Ethernet.h>
#include <EthernetUdp.h>


//
void readVoltage() {
  int new_reading = analogRead(analog_pin);
  if (new_reading > max_reading) {
    max_reading = new_reading;
  }
  num_data_points = ++num_data_points % MAX_INT;
}

//
boolean messageReceived() {
  packet_size = Udp.parsePacket();
  return packet_size > 0;
}

//
void processMessage() {

    parseRawMessage();

    if (strcmp(header,H_REQ_RSS) == 0) {
      Serial.println("=====================");
      Serial.print(num_data_points);Serial.print(" points -> ");Serial.println(max_reading * 5.0 / 1023); 
      // Send back data
      sendMaxReading();
      // Reset max
      max_reading = 0;
      // Reset data points counter
      num_data_points = 0;
    } else if (strcmp(header,H_REQ_NOISE_FLOOR) == 0) {
      // Poll for the noise floor
      determineNoiseFloor();
      // Reply to the sender with the noise floor
      sendMaxReading();
    }
}

//
void sendMaxReading() {
  Serial.println("sending");
    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    Udp.write(MSG_RSS);
    Udp.write(dconv.floatToBytes(max_reading * 5.0 / 1023));
    Udp.endPacket();
}

void parseRawMessage() {
    // read the packet into packetBufffer
    Udp.read(raw_message, UDP_TX_PACKET_MAX_SIZE);
    
    // Parse header
    for (int i = 0; i < 3; i += 1) {
      header[i] = raw_message[i];
    }

    // Parse data
    for (int i = 0; i < packet_size - 4; i += 1) {
      data[i] = raw_message[4 + i];
    }
}

//
void determineNoiseFloor() {
  // Poll for 5 seconds, and store the max reading as the noise floor
  unsigned long start_time = millis();
  num_data_points = 0;
  Serial.println("Polling for noise floor...");
  while (millis() - start_time < 5000) {
     readVoltage();
  }
  Serial.print("Noise floor: ");Serial.println(max_reading * 5.0 / 1023);
  sendMaxReading();
}

//
void printSource() {
    Serial.print("Received packet of size ");
    Serial.println(packet_size);
    Serial.print("From ");
    IPAddress remote = Udp.remoteIP();
    for (int i = 0; i < 4; i++)
    {
      Serial.print(remote[i], DEC);
      if (i < 3)
      {
        Serial.print(".");
      }
    }
    Serial.print(", port ");
    Serial.println(Udp.remotePort());
}
