/*
This file contains the definitions of message headers for the created protocol
*/

#ifndef protocol_h
#define protocol_h

// Message constants for sending outgoing messages
#define MSG_REQ_NOISE_FLOOR "201|"
#define MSG_NOISE_FLOOR "202|"
#define MSG_REQ_PIN_VOLTAGE "203|"
#define MSG_PIN_VOLTAGE "204|"

// Message header constants used for decoding incoming messages
#define H_REQ_NOISE_FLOOR "201"
#define H_NOISE_FLOOR "202"
#define H_REQ_PIN_VOLTAGE "203"
#define H_PIN_VOLTAGE "204"

#endif