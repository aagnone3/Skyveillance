import processing.core.*;
import java.util.LinkedList;

// Background color
public final int BACKGROUND_COLOR = 250;
// Colors to use for plotting
public final int[] COLORS = new int[] {0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFF00FF};

// Various initialization
public void initDisplay(boolean logging_data) {
  stroke(0);
  fill(0);
  background(BACKGROUND_COLOR);
  
  textSize(12);
  text("press 'n' to set noise floor", 10, 20);
  text("press 's' to start polling data", 10, 40);
  line(0, 50, WINDOW_WIDTH, 50);
  
  initPinVoltagePlotting();
  //line(250,350,400,350);
  initPositionEstimation();
}