
// Constant data members
public final float DIST_OFFSET_X = 500.0;
public final float DIST_OFFSET_Y = 300.0;
public final float DIST_X_INCREMENT = 10.0;
public final float MAX_DISTANCE = 10;
public final float DIST_PLOT_HEIGHT = 200.0;
public final float DIST_PLOT_WIDTH = 400;
public final float DIST_MAX_Y = DIST_OFFSET_Y - DIST_PLOT_HEIGHT;
public final float PIXELS_PER_INCH = DIST_PLOT_HEIGHT / MAX_DISTANCE;
public final int DIST_NUM_X_POINTS = (int)(DIST_PLOT_WIDTH / DIST_X_INCREMENT) - 1;
public final float DIST_Y_AXIS_TICK = 0.5;
public final float DIST_NUM_Y_AXIS_TICKS = MAX_DISTANCE / DIST_Y_AXIS_TICK;

// Non-constant data members
public LinkedList<float[]> dist_data;
public float dist_cur_x;
public float dist_last_x;
public float[] dist_last_data;
public float[] dist_prev_removed;

// Various initialization
void initDistPlotting() {
  // Initialize data as necessary
  dist_data = new LinkedList<float[]>();
  dist_last_data = new float[NUM_CLIENTS];
  dist_prev_removed = new float[NUM_CLIENTS];
  for (int i = 0; i < NUM_CLIENTS; i +=1 ) {
    dist_prev_removed[i] = DIST_OFFSET_Y;
  }
  
  // Write plot title and axis labels
  stroke(0);
  fill(0);
  textSize(18);
  text("Distances", DIST_OFFSET_X + (DIST_PLOT_WIDTH / 3), 75);
  textSize(10);
  text("Samples", DIST_OFFSET_X + (DIST_PLOT_WIDTH/2), DIST_OFFSET_Y + 15);
  
  // Print y axis tick marks
  for (float v = DIST_Y_AXIS_TICK; v < MAX_DISTANCE; v += DIST_Y_AXIS_TICK) {
    line(DIST_OFFSET_X - 5, DIST_OFFSET_Y - (v * PIXELS_PER_INCH), DIST_OFFSET_X, DIST_OFFSET_Y - (v * PIXELS_PER_INCH));
    String s = str(v);
    text(s.substring(0, 3), DIST_OFFSET_X - 5 - 17, DIST_OFFSET_Y - (v * PIXELS_PER_INCH) + 3);
  }
  
  // Draw the actual axes
  drawDistanceAxes();
}

// Redraw the axes for the distance plot
void drawDistanceAxes() {
  stroke(0);
  fill(0);
  
  line(DIST_OFFSET_X, DIST_MAX_Y,
       DIST_OFFSET_X, DIST_OFFSET_Y);
  line(DIST_OFFSET_X, DIST_OFFSET_Y,
       DIST_OFFSET_X + DIST_PLOT_WIDTH, DIST_OFFSET_Y);
}

// Plot the current set of data points
public void plotDistances(double[] new_points) {
  handleOldDataPoints();
  addNewDistances(new_points);
  plotAllDataPoints();
  drawDistanceAxes();
}

// Process the phasing out of data points for correct behavior
// of the moving plot
void handleOldDataPoints() {
  // Remove oldest data point if we are at our # data points limit
  if (dist_data.size() == DIST_NUM_X_POINTS) {
    // Remove the oldest data point
    dist_prev_removed = dist_data.removeFirst();
    
    // Set "last" data points to be the data points of the previously-removed data point
    for (int i = 0; i < NUM_CLIENTS; i += 1) {
      dist_last_data[i] = DIST_OFFSET_Y - (dist_prev_removed[i] * PIXELS_PER_INCH);
    }
    
    //
    blankOutDistanceXYPlane();
  } else {
    // Set "last" data points to be y=0
    for (int i = 0; i < NUM_CLIENTS; i += 1) {
      dist_last_data[i] = DIST_OFFSET_Y;
    }
  } 
}

// Blank out the plot for replotting purposes
void blankOutDistanceXYPlane() {
  fill(BACKGROUND_COLOR);
  stroke(BACKGROUND_COLOR);
  rect(DIST_OFFSET_X+1, DIST_MAX_Y, DIST_PLOT_WIDTH-1, DIST_OFFSET_Y - DIST_MAX_Y - 1);
}

// Add the new set of data points
void addNewDistances(double[] new_points) {
  // Add the new data point
  // Saturate value to MAX_DISTANCE if out of range for plot
  float[] arr = new float[new_points.length];
  for (int i = 0; i < new_points.length; i += 1) {
    arr[i] = dataPointInRange(new_points[i]) ? (float)new_points[i] : MAX_DISTANCE;
  }
  dist_data.addLast(arr); 
}

// Determine whether the data point is in range for the plot
boolean dataPointInRange(double point) {
  return point > 0 && point < MAX_DISTANCE;
}

// Plot all data points
void plotAllDataPoints() {
  // Set initial x coordinates for plotting
  dist_last_x = DIST_OFFSET_X;
  dist_cur_x = DIST_OFFSET_X + DIST_X_INCREMENT;
  
  // Plot each set of data points
  for (float[] data_set : dist_data) {
    // Plot data for each node
    for (int i = 0; i < NUM_CLIENTS; i += 1) {
      stroke(COLORS[i]);
      line(dist_last_x, dist_last_data[i], dist_cur_x, DIST_OFFSET_Y - (data_set[i] * PIXELS_PER_INCH));
      dist_last_data[i] = DIST_OFFSET_Y - (data_set[i] * PIXELS_PER_INCH); 
    }
    dist_last_x = dist_cur_x;
    dist_cur_x += DIST_X_INCREMENT;
  } 
}