/*
 */

#include "Message.h"

  Message::Message() {
    header = "n/a";
    //contents = "n/a";
    contents = (char*)malloc(sizeof(char)*UDP_TX_PACKET_MAX_SIZE);
    valid = false;
  }

  Message::Message(char* raw, unsigned int packet_size) {
    parse(raw, packet_size);
  }

  Message::~Message() {
    delete contents;
    delete raw;
    contents = NULL;
    raw = NULL;
  }

  String Message::getHeader() const {
    return header;
  }

  void Message::setHeader(String header) {
    this->header = header;
  }

  char* Message::getContents() const {
    //char bytes[4];
    //contents.toCharArray(bytes, 4);
    return contents;
  }

  void Message::setContents(char* contents) {
    this->contents = contents;
  }

  void Message::parse(char* raw, unsigned int packet_size) {
    this->raw = raw;
    this->packet_size = packet_size;

    String msg(raw);
    this->message = msg;

    int pos = msg.indexOf("|");
    if (pos > -1) valid = true;
    this->header = msg.substring(0, pos);
    //Serial.print("parse");Serial.println(this->header);

    //contents = (char*)malloc(sizeof(char)*packet_size - 3);
    for (int i = 0; i < packet_size - 3; ++i) {
      this->contents[i] = raw[4 + i];
    }
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
