/*
The Message class handles the specific details of parsing a network message.
 */

#ifndef message_h
#define message_h

#include "Arduino.h"
#include "Ethernet.h"
#include "DataConverter.h"

class Message {

private:
	// Header of the message
	String header;
	// Content of the message
	char* contents;
  // Validation flag
  bool valid;
  // Raw byte array of the message
  char* raw;
  // String representation of the message
  String message;
  // size of the packet received
  unsigned int packet_size;

public:
  // Constructor
  Message();
  Message(char*,unsigned int);
  ~Message();

  // Return the header
  String getHeader() const;
  // Set the header
  void setHeader(String);
  // Return the message contents
  char* getContents() const;
  // Set the message contents
  void setContents(char*);
  // Parse the header and contents of the raw message
  void parse(char*, unsigned int);
  // Compare the given header with this string's header
  bool hasHeader(const char* header);
  // Return whether the current data is valid for the network's protocol
  bool isValid();
  // Clear data
  void clear();
};

#endif
