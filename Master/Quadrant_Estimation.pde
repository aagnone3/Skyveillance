public final float EST_X_OFFSET = 250.0;
public final float EST_Y_OFFSET = 300.0;
public final float EST_WIDTH = 400.0;
public final float EST_HEIGHT = 400.0;
public final int HYSTERESIS_TIMEOUT = 1500;

public int new_estimate_hysteresis;
public int last_temp_estimate;
public int current_official_estimate;
public boolean in_hysteresis;

public void initQuadrantEstimation() {
  new_estimate_hysteresis = millis();
  current_official_estimate = 1;
  last_temp_estimate = 1;
  in_hysteresis = false;
  drawEstimationAxes();
}

public void updateQuadrantEstimate(float[] voltages) {
  int max_index = 0;
  double max_pin_voltage = voltages[0];
  for (int i = 1; i < NUM_CLIENTS; i += 1) { 
    if (voltages[i] > max_pin_voltage) {
      max_pin_voltage = voltages[i];
      max_index = i;
    }
  }
  confirmEstimate(max_index);
}
/*
public void assessCurrentEstimate(int temp_estimate) {
  if (temp_estimate != current_official_estimate) {
    if (in_hysteresis && millis() - new_estimate_hysteresis > HYSTERESIS_TIMEOUT) {
      // New guess has been made for longer than HYSTERESIS_TIMEOUT, change the
      // official quadrant estimate
      newEstimate(temp_estimate);
    } else if (!in_hysteresis) {
      in_hysteresis = true;
      new_estimate_hysteresis = millis();
    }
    // Else keep waiting
  } else {
    // Temporary estimate is the same as the current official estimate.
    // Kill the change hysteresis timer if it is running
    if (in_hysteresis) {
      in_hysteresis = false;
    }
  }
}
*/

public void confirmEstimate(int index) {
  fillQuadrant(index + 1);
  drawEstimationAxes();
}

public void drawEstimationAxes() {
  stroke(0);
  fill(0);
  line(250, 350, 650, 350); // top
  line(250, 650, 650, 650); // bottom
  line(250, 350, 250, 650); // left
  line(650, 350, 650, 650); // right
  line(450, 350, 450, 650); // middle vertical
  line(250, 500, 650, 500); // middle horizontal
}

public void fillQuadrant(int quadrant) {
  int fill_index = quadrant - 1;
  
  for (int i = 0; i < NUM_CLIENTS; i += 1) {
    fill( (i == fill_index ? COLORS[fill_index] : 255) );
    if (i == 0) {
      rect(450, 350, 200, 150);
    } else if (i == 1) {
      rect(250, 350, 200, 150);
    } else if (i == 2) {
      rect(250, 500, 200, 150);
    } else {
      rect(450, 500, 200, 150);
    }
  }
}