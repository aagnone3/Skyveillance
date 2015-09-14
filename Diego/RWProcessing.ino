char val;
int sensorPin = A0; 
int ledPin = 13;      
int sensorValue = 0;
boolean ledState = LOW;
int droneX = 311;
int droneY = 206;
int droneH = 29;

void setup() {
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
  establishContact();
}

void loop() {
  if (Serial.available()) { //receive
    /*
    val = Serial.read();
    if(val == "1") {
      ledState != ledState;
      digitalWrite(ledPin, ledState);
    }
    delay(100)
    */
    delay(100);
  } else { //send
    Serial.println("Start");
    Serial.println(droneX);
    Serial.println(droneY);
    Serial.println(droneH);
    //sensorValue = analogRead(sensorPin);
    delay(50);
  }
}

void establishContact() {
  while(Serial.available()) {
    Serial.println("test");
    delay(300);
  }
}

