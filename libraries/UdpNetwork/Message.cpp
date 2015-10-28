/*
 */

#include "Message.h"

  Message::Message() {
    contents = new char[UDP_TX_PACKET_MAX_SIZE];
    valid = false;
  }

  /*
  Message::Message(char* raw, unsigned int packet_size) {
    parse(raw, packet_size);
  }
  */

  Message::~Message() {
    delete[] contents;
    contents = NULL;
  }

  const char* Message::getHeader() const {
    return header;
  }

  char* Message::getContents() const {
    return contents;
  }

  void Message::setContents(char* contents) {
    this->contents = contents;
  }
  
  void Message::parseHeader(char* msg) {
    header[0] = msg[0];
    header[1] = msg[1];
    header[2] = msg[2];
  }

  void Message::clearMessage() {
    // Clear message header
    header[0] = '4';
    header[1] = '0';
    header[2] = '4';

    // Clear message contents
    for (int i = 0; i < UDP_TX_PACKET_MAX_SIZE; ++i) {
      contents[i] = '9';
    }

    // Clear the sender IPAddress
    sender = INADDR_NONE;
  }

  IPAddress Message::getSender() {
    return sender;
  }

  void Message::parse(char* raw, int packet_size, IPAddress sender) {
    clear();
    this->sender = sender;

    valid = true;
    parseHeader(raw);

    for (int i = 0; i < packet_size - 4; ++i) {
      contents[i] = raw[4 + i];
    }

    //Serial.print("Raw: ");Serial.print(raw);Serial.println();
    //Serial.print("Header: ");Serial.print(header);Serial.println();
	  //Serial.print("Contents:");Serial.print(contents);Serial.println();
  }

  bool Message::hasHeader(const char* h) {
    return header == h;
  }

  bool Message::isValid() {
    return valid;
  }

  void Message::clear() {
    /*
    Serial.println("clear");
    header = "n/a";
    contents = "n/a";
    */
  }
