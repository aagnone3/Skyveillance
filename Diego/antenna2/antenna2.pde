import processing.serial.*;

//int y = 100;
int droneX = 100;
int droneY = 100;
int droneH = 100;
PImage ant;
Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port


void setup() {
  size(800, 600);
  ant = loadImage("ant.png");
  String portName = Serial.list()[3]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  //stroke(255);
}

void draw() {
  background(0, 0, 0);
  rectMode(CENTER);
  ellipseMode(CENTER);
  
  //Read In
  String temp;
  String temp2;
  String temp3;
  //Read Serial
  
  if ( myPort.available() > 0) { 
    temp = myPort.readStringUntil('\n');
    //println(temp.substring(0, temp.length()-2));
    if(temp != null && !temp.equals("\n") && temp.substring(0, temp.length()-2).equals("Start")) { //Send Start, x, y, z
      //println("YEHAHAH");
      temp = (myPort.readStringUntil('\n'));
      println(temp);
      temp2 = (myPort.readStringUntil('\n'));
      //println(temp2);
      temp3 = (myPort.readStringUntil('\n'));
      //println(temp3);
      if(temp != null && temp2 != null && temp3 != null) {
        droneX = parseInt(temp.substring(0, temp.length()-2)); //separate with "\n"
        //println(temp.substring(0, temp.length()-1));
        droneY = parseInt(temp2.substring(0, temp2.length()-2));
        droneH = parseInt(temp3.substring(0, temp3.length()-2));
      }
    }
  } 
  
  //Mouse Test
  //droneX = mouseX;
  //droneY = mouseY;
  
  //antenna drawing
  ant();
  
  //drone
  drone(droneX, droneY);
  
  //texts
  textSize(32);
  text("Skyveillance Beta", 260, 40);
  textSize(16);
  text("x = " + droneX + ", y = " + droneY + ", Height = " + droneH, 280, height- 20);
  
  //antennas
  //antenna(width/2-10, 60, 1);
  //antenna(25, height-25, 2);
  //antenna(width-45, height-25, 3);
  
  
}

void drone(int x, int y) {
  //noFill();
  stroke(0);
  rect(x+2.5, y+2.5, 10, 10);
  ellipse(x-5, y-5, 10, 10);
  ellipse(x+5, y-5, 10, 10);
  ellipse(x-5, y+5, 10, 10);
  ellipse(x+5, y+5, 10, 10); 
}

void antenna(int x, int y, int direction) {
  stroke(0);
  triangle(x, y, x+20, y, x+10, y-35);
  stroke(255);
  curve(x-5, y-15, x-5, y-25, x+5, y-35, x+15, y-35);
  pushMatrix();
  scale(1.5);
  translate(-378, -275);
  curve(x-5, y-15, x-5, y-25, x+5, y-35, x+15, y-35);
  popMatrix();
}

void ant() {
  pushMatrix();
  scale(1, -1);
  image(ant, 10, -60, 50, 50);
  popMatrix();
  pushMatrix();
  scale(-1, 1);
  image(ant, -width+10, height-60, 50, 50);
  popMatrix();
  pushMatrix();
  scale(-1, -1);
  image(ant, -width+10, -60, 50, 50);
  popMatrix();
  image(ant, 10, height-60, 50, 50);
}