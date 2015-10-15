/*
 */

#include "Message.h"

  Message::Message() {
    contents = (char*)malloc(sizeof(char)*UDP_TX_PACKET_MAX_SIZE);
    valid = false;
  }

  /*
  Message::Message(char* raw, unsigned int packet_size) {
    parse(raw, packet_size);
  }
  */

  Message::~Message() {
    delete contents;
    //delete raw;
    contents = NULL;
    //raw = NULL;
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

  void Message::parse(char* raw, int packet_size) {
    //this->raw = raw;
    //this->packet_size = packet_size;

    //String msg(raw);
    //this->message = msg;

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
