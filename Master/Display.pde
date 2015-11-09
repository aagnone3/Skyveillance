import processing.core.*;

public void initDisplay(boolean logging_data) {
  textSize(18);
  fill(0);
  text("press 'n' to set noise floor", 10, 30);
  fill(0);
  text("press 's' to start polling data", 10, 60);
  
  textSize(24);
  String msg = "";
  if (!logging_data) {
    // Show the user that data will NOT be logged
    fill(255, 0, 0);
    msg = "WON'T LOG DATA";
  } else {
    // Show the user that data WILL be logged
    fill(150, 255, 150);
    msg = "Will log data";
  }
  text(msg, 10, 100);
}