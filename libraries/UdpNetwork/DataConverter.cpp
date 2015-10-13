
#include "DataConverter.h"

char* DataConverter::floatToBytes(float f) {
	d.num = f;
	return d.bytes;
}

float DataConverter::bytesToFloat(char* b) {
	d.bytes[0] = b[0];
	d.bytes[1] = b[1];
	d.bytes[2] = b[2];
	d.bytes[3] = b[3];
	return d.num;
};
