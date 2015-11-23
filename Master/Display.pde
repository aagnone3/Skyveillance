import processing.core.*;
import java.util.LinkedList;

// Constants
public final int BACKGROUND_COLOR = 250;
public final int[] COLORS = new int[] {0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFF00FF};

// Non-constant data members

public void initDisplay(boolean logging_data) {
  stroke(0);
  fill(0);
  background(BACKGROUND_COLOR);
  
  textSize(12);
  text("press 'n' to set noise floor", 10, 20);
  text("press 's' to start polling data", 10, 40);
  line(0, 50, WINDOW_WIDTH, 50);
  
  initPinVoltagePlotting();
  initDistPlotting();
  //line(250,350,400,350);
  initQuadrantEstimation();
  
  /*
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
  
  fill(0);
  
  text("** For logging to work **", 10, 150);
  textSize(18);
  text("  1) Click the 'x' button of this window", 10, 180);
  text("  2) Click the stop button of the script window", 10, 200);
  */
}