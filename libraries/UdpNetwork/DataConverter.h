/*
The DataConverter class handles easy conversion between floats and bytes, to make it easy
to send float data over the network.
*/

#ifndef dataconverter_h
#define dataconverter_h

#include "Arduino.h"

class DataConverter {

private:
	// Union data type let's you store two different kinds of data in the same memory location
	// This allows ease of sending float data as bytes
	typedef union {
		float num;
		char bytes[4];
	} Data;
	Data d;

public:
	// Convert the float into bytes
	char* floatToBytes(float);
	// Convert the bytes into its representative float
	float bytesToFloat(char*);
};

#endif