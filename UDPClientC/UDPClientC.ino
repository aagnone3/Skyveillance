#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <Protocol.h>
#include <DataConverter.h>

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {
  0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC
};
IPAddress ip(192, 168, 1, 3);
unsigned int local_port = 8888;
int analog_pin = A5;
int packet_size;
unsigned int num_data_points;
const unsigned int MIN_DATA_POINTS = 100;
unsigned int max_reading;
unsigned int MAX_INT = (2 << 16) - 1;

// buffers for receiving and sending data
char header[4];
char raw_message[UDP_TX_PACKET_MAX_SIZE];
char data[UDP_TX_PACKET_MAX_SIZE];

// An EthernetUDP instance to let us send and receive packets over UDP
EthernetUDP Udp;
DataConverter dconv;

// Function headers
void readVoltage();
void processMessage();
void sendMaxReading();
void parseMessage();
void clearBuffer();
void determineNoiseFloor();
void printSource();
boolean messageReceived();
boolean isValidMsg();

void setup() {
  // start the Ethernet and UDP:
  Ethernet.begin(mac, ip);
  Udp.begin(local_port);
  Serial.begin(9600);

  header[0] = '0';
  header[1] = '0';
  header[2] = '0';

  Serial.println("Setup complete.");
}

void loop() {
  // if there's data available, read a packet
  if (messageReceived() && num_data_points > MIN_DATA_POINTS) {
    processMessage();
  }

  // Take a new reading from the analog pin
  readVoltage();

  // Wait for ADC to settle
  delay(2);
}


/* ====================================
     Helper function implementations 
   ====================================         
*/

//
void readVoltage() {
  int new_reading = analogRead(analog_pin);
  if (new_reading > max_reading) {
    max_reading = new_reading;
  }
  num_data_points = ++num_data_points % MAX_INT;
}

//
void processMessage() {

    // read the packet into packetBufffer
    Udp.read(raw_message, UDP_TX_PACKET_MAX_SIZE);

    // Only process recognized messages according to the protocol
    if (isValidMessage()) {

        // Parse the message's header and data fields
        parseMessage();
        // Process the message, according to its header
        if (strcmp(header,H_REQ_PIN_VOLTAGE) == 0) {
          Serial.print(num_data_points);
          //Serial.println("=====================");
          //Serial.print(num_data_points);Serial.print(" points -> ");Serial.println(max_reading * 5.0 / 1023); 
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

    // Clear the buffer
    clearBuffer();
}

//
void sendMaxReading() {
  Serial.println("Sending reading");
    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    Udp.write(MSG_PIN_VOLTAGE);
    Udp.write(dconv.floatToBytes(max_reading * 5.0 / 1023));
    Udp.endPacket();
}

void parseMessage() {

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
void clearBuffer() {
  for (int i = 0; i < UDP_TX_PACKET_MAX_SIZE; i += 1) {
    raw_message[i] = '0';
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

//
boolean messageReceived() {
  packet_size = Udp.parsePacket();
  return packet_size > 0;
}

//
boolean isValidMessage() {
  return (packet_size >= 4);
}


