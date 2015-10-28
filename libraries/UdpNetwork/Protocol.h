/*
This file contains the definitions of message headers for the created protocol
*/

#ifndef protocol_h
#define protocol_h

// Message constants for sending outgoing messages
#define MSG_REQ_REGISTRATION "100|"
#define MSG_ACK_REGISTRATION_REQ "101|"
#define MSG_RESET_CMD "102|"
#define MSG_RESET_ACK "103|"
#define MSG_RESET_COMPLETE "104|"
#define MSG_DATA "200|"
#define MSG_NOISE_FLOOR "201|"
#define MSG_ACK_NOISE_FLOOR "202|"
#define MSG_REQ_RSS "203|"
#define MSG_RSS "204|"
#define MSG_REQ_NOISE_FLOOR "205|"

// Message header constants used for decoding incoming messages
#define H_REQ_REGISTRATION "100"
#define H_ACK_REGISTRATION_REQ "101"
#define H_RESET_CMD "102"
#define H_RESET_ACK "103"
#define H_RESET_COMPLETE "104"
#define H_DATA "200"
#define H_NOISE_FLOOR "201"
#define H_ACK_NOISE_FLOOR "202"
#define H_REQ_RSS "203"
#define H_RSS "204"
#define H_REQ_NOISE_FLOOR "205"

#endif