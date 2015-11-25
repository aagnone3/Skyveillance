
// Constant data members
public final float OFFSET_X = 100.0;
public final float OFFSET_Y = 300.0;
public final float X_INCREMENT = 10.0;
public final float MAX_VOLTAGE = 1.8;
public final float HEIGHT = 200.0;
public final float WIDTH = 800;
public final float TOP_Y = OFFSET_Y - HEIGHT;
public final float PIXELS_PER_VOLT = HEIGHT / MAX_VOLTAGE;
public final int NUM_X_POINTS = (int)(WIDTH / X_INCREMENT) - 1;
public final float Y_AXIS_TICK = 0.2;
public final float NUM_Y_AXIS_TICKS = MAX_VOLTAGE / Y_AXIS_TICK;

// Non-constant data members
public LinkedList<float[]> pin_voltages;
public float current_x;
public float last_x;
public float[] last_pin_voltages;
public float[] previously_removed;

// Various initialization
void initPinVoltagePlotting() {
  // Initialize data as necessary
  pin_voltages = new LinkedList<float[]>();
  last_pin_voltages = new float[NUM_CLIENTS];
  previously_removed = new float[NUM_CLIENTS];
  for (int i = 0; i < NUM_CLIENTS; i +=1 ) {
    previously_removed[i] = OFFSET_Y;
  }
  
  // Write plot title and axis labels
  stroke(0);
  fill(0);
  // Title
  textSize(18);
  text("Pin Voltage Samples", OFFSET_X + (WIDTH / 2.5), 85);
  // X Axis Labels
  textSize(10);
  text("Samples", OFFSET_X + (WIDTH/2), OFFSET_Y + 15);
  // Y Axis Labels
  text("Pin Voltage", OFFSET_X - 90, OFFSET_Y - (HEIGHT/2));
  text("[V]", OFFSET_X - 70, OFFSET_Y - (HEIGHT/2) + 10);
  
  // Print y axis tick marks for left and right side
  for (float v = Y_AXIS_TICK; v < MAX_VOLTAGE; v += Y_AXIS_TICK) {
    line(OFFSET_X - 2, OFFSET_Y - (v * PIXELS_PER_VOLT), OFFSET_X + 3, OFFSET_Y - (v * PIXELS_PER_VOLT));
    line(OFFSET_X + WIDTH - 3, OFFSET_Y - (v * PIXELS_PER_VOLT), OFFSET_X + WIDTH + 5, OFFSET_Y - (v * PIXELS_PER_VOLT));
    String s = str(v);
    text(s.substring(0, 3), OFFSET_X - 5 - 17, OFFSET_Y - (v * PIXELS_PER_VOLT) + 3);
    text(s.substring(0, 3), OFFSET_X  + WIDTH + 5, OFFSET_Y - (v * PIXELS_PER_VOLT) + 3);
  }
  
  // Draw the actual axes
  drawPinVoltageAxes();
}

// Redraw the plot axes
void drawPinVoltageAxes() {
  stroke(0);
  fill(0);
  
  line(OFFSET_X, TOP_Y,
       OFFSET_X, OFFSET_Y);
  line(OFFSET_X, OFFSET_Y,
       OFFSET_X + WIDTH, OFFSET_Y);
  line(OFFSET_X + WIDTH, TOP_Y,
       OFFSET_X + WIDTH, OFFSET_Y);
}

// Blank out the plot for replotting purposes
void blankOutPinVoltageXYPlane() {
  fill(BACKGROUND_COLOR);
  stroke(BACKGROUND_COLOR);
  rect(OFFSET_X+1, TOP_Y, WIDTH-1, OFFSET_Y - TOP_Y - 1);
}

// Plot the new set of data points
public void plotPinVoltages(float[] new_points) {
  handleOldPinVoltages();
  addNewPinVoltage(new_points);
  plotAllPinVoltages();
  drawPinVoltageAxes();
}

// Add a new data point
void addNewPinVoltage(float[] new_points) { 
  // Add the new data point
  // Saturate value to MAX_DISTANCE if out of range for plot
  float[] arr = new float[new_points.length];
  for (int i = 0; i < new_points.length; i += 1) {
    arr[i] = (new_points[i] > 0 && new_points[i] < MAX_VOLTAGE) ?
             (float)new_points[i] : MAX_VOLTAGE;
  }
  // Add the new data point
  pin_voltages.addLast(arr);
}

// Process the phasing out of data points for correct behavior
// of the moving plot
void handleOldPinVoltages() {
  // Remove oldest data point if we are at our # data points limit
  if (pin_voltages.size() == NUM_X_POINTS) {
    // Remove the oldest data point
    previously_removed = pin_voltages.removeFirst();
    
    // Set "last" data points to be the data points of the previously-removed data point
    for (int i = 0; i < NUM_CLIENTS; i += 1) {
      last_pin_voltages[i] = OFFSET_Y - ((previously_removed[i]) * PIXELS_PER_VOLT);
      //last_pin_voltages[i] = OFFSET_Y - ((previously_removed[i] - noise_floors[i]) * PIXELS_PER_VOLT);
    }
    
    //
    blankOutPinVoltageXYPlane();
  } else {
    // Set "last" data points to be y=0
    for (int i = 0; i < NUM_CLIENTS; i += 1) {
      last_pin_voltages[i] = OFFSET_Y;
    }
  }
}

// Plot all relevant data points
void plotAllPinVoltages() {
  // Set initial x coordinates for plotting
  last_x = OFFSET_X;
  current_x = OFFSET_X + X_INCREMENT;
  
  // Loop through each set of data points
  for (float[] data_set : pin_voltages) {
    // Plot data for each node
    for (int i = 0; i < NUM_CLIENTS; i += 1) {
      stroke(COLORS[i]);
      //float current_y = OFFSET_Y - ((data_set[i] - noise_floors[i]) * PIXELS_PER_VOLT);if
      float current_y = OFFSET_Y - ((data_set[i]) * PIXELS_PER_VOLT);
      line(last_x, last_pin_voltages[i], current_x, current_y);
      last_pin_voltages[i] = current_y;
    }
    last_x = current_x;
    current_x += X_INCREMENT;
  } 
}