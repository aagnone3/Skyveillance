public final float EST_X_OFFSET = 250.0;
public final float EST_Y_OFFSET = 350.0;
public final float EST_WIDTH = 400.0;
public final float EST_HEIGHT = 400.0;
public final int HYSTERESIS_TIMEOUT = 1500;
public final float CLOSE_THRESH = 0.1;
public final float FAR_THRESH = 0.2;

public int new_estimate_hysteresis;
public int last_temp_estimate;
public int current_official_estimate;
public boolean in_hysteresis;

public void initPositionEstimation() {
  new_estimate_hysteresis = millis();
  current_official_estimate = 1;
  last_temp_estimate = 1;
  in_hysteresis = false;
  drawEstimationGrid();
}

public void updatePositionEstimate(float[] voltages) {
  // Get array index of max pin voltage
  int index = indexOfMaxPinVoltage(voltages);
  int square = getCurrentEstimate(index, voltages);
  confirmEstimate(square, COLORS[index]);
}

public int getCurrentEstimate(int max_index, float[] voltages) {
  // Compare the difference in magnitude between other pin voltages
  // This will tell you whether the estimate should be in a node's region,
  //   or in between the regions of two nodes
  float[] differences = new float[NUM_CLIENTS - 1];
  int difIndx = 0,
      numCloseNodes = 0,
      numFarNodes = 0,
      squareEstimate = 0;
  for (int i = 0; i < NUM_CLIENTS; i += 1) {
    if (i != max_index) {
      differences[difIndx] = voltages[max_index] - voltages[i];
      if (differences[difIndx] < CLOSE_THRESH) {
        numCloseNodes += 1;
      } else if (differences[difIndx] > FAR_THRESH) {
        numFarNodes += 1;
      }
      difIndx++;
    }
  }
  
  if (numFarNodes == 3) {
    // Estimate is the region which contains the node with the max pin voltage
    squareEstimate = squareWithNode(max_index);
  } else if (numFarNodes == 2) {
    // Estimate is the region between one of the two other nodes
    int[] oppositeNodeIndices = indicesOfOpposites(max_index);
    for (int i = 0; i < oppositeNodeIndices.length; i += 1) {
      if (voltages[max_index] - voltages[oppositeNodeIndices[i]] < CLOSE_THRESH) {
        // Estimate is the region between these two nodes
        squareEstimate = transitionRegionBetween(max_index, oppositeNodeIndices[i]);
      }
    }
  } else {
    // Estimate center node
    squareEstimate = 5;
  }
  
  println(squareEstimate);
  return squareEstimate;
}

public int squareWithNode(int indx) {
  if (indx == 0) {
    return 1;
  } else if (indx == 1) {
    return 3;
  } else if (indx == 2) {
    return 7;
  }
  return 9;
}

public int transitionRegionBetween(int indx1, int indx2) {
  int regionIndx = -1;
  if (indx1 == 0 && indx2 == 2) {
    regionIndx = 4;
  } else if (indx1 == 0 && indx2 == 1) {
    regionIndx = 2;
  } else if (indx1 == 0 && indx2 == 3) {
    regionIndx = 5;
  } else if (indx1 == 2 && indx2 == 3) {
    regionIndx = 8;
  } else {
    regionIndx = 6;
  }
  return regionIndx;
}

public int indexOfMaxPinVoltage(float[] voltages) {
  int max_index = 0;
  double max_pin_voltage = voltages[0];
  for (int i = 1; i < NUM_CLIENTS; i += 1) { 
    if (voltages[i] > max_pin_voltage) {
      max_pin_voltage = voltages[i];
      max_index = i;
    }
  }
  return max_index;
}

public int[] indicesOfOpposites(int indx) {
  int[] indices = new int[2];
  if (indx == 0) {
    indices[0] = 1;
    indices[1] = 2;
  } else if (indx == 1) {
    indices[0] = 0;
    indices[1] = 3;
  } else if (indx == 2) {
    indices[0] = 0;
    indices[1] = 3;
  } else {
    indices[0] = 1;
    indices[1] = 2;
  }
  return indices;
}

/*
public void assessCurrentEstimate(int temp_estimate) {
  if (temp_estimate != current_official_estimate) {
    if (in_hysteresis && millis() - new_estimate_hysteresis > HYSTERESIS_TIMEOUT) {
      // New guess has been made for longer than HYSTERESIS_TIMEOUT, change the
      // official position estimate
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

public void confirmEstimate(int squareNum, int fillColor) {
  clearSquares();
  fillSquare(squareNum, fillColor);
  drawEstimationGrid();
}

public void drawEstimationGrid() {
  stroke(0);
  fill(0);
  // Top
  line(EST_X_OFFSET, EST_Y_OFFSET,
       EST_X_OFFSET + EST_WIDTH, EST_Y_OFFSET);
  // Bottom
  line(EST_X_OFFSET, EST_Y_OFFSET + EST_HEIGHT,
       EST_X_OFFSET + EST_WIDTH, EST_Y_OFFSET + EST_HEIGHT);
  // Left
  line(EST_X_OFFSET, EST_Y_OFFSET,
       EST_X_OFFSET, EST_Y_OFFSET + EST_HEIGHT);
  // Right
  line(EST_X_OFFSET + EST_WIDTH, EST_Y_OFFSET,
       EST_X_OFFSET + EST_WIDTH, EST_Y_OFFSET + EST_HEIGHT);
  // Middle Vertical 1
  line(EST_X_OFFSET + (EST_WIDTH / 3), EST_Y_OFFSET,
       EST_X_OFFSET + (EST_WIDTH / 3), EST_Y_OFFSET + EST_HEIGHT);
  // Middle Horizontal 1
  line(EST_X_OFFSET, EST_Y_OFFSET + (EST_HEIGHT / 3),
       EST_X_OFFSET + EST_WIDTH, EST_Y_OFFSET + (EST_HEIGHT / 3));
  // Middle Vertical 2
  line(EST_X_OFFSET + (2 * EST_WIDTH / 3), EST_Y_OFFSET,
       EST_X_OFFSET + (2 * EST_WIDTH / 3), EST_Y_OFFSET + EST_HEIGHT);
  // Middle Horizontal 2
  line(EST_X_OFFSET, EST_Y_OFFSET + (2 * EST_HEIGHT / 3),
       EST_X_OFFSET + EST_WIDTH, EST_Y_OFFSET + (2 * EST_HEIGHT / 3));
}

public void clearSquares() {
  // White out all squares
  for (int i = 1; i < 10; i += 1) {
    fill(255);
    if (i == 1) {
      rect(EST_X_OFFSET, EST_Y_OFFSET,
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 2) {
      rect(EST_X_OFFSET + (EST_WIDTH/3), EST_Y_OFFSET,
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 3) {
      rect(EST_X_OFFSET + (2*EST_WIDTH/3), EST_Y_OFFSET,
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 4) {
      rect(EST_X_OFFSET, EST_Y_OFFSET + (EST_HEIGHT/3),
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 5) {
      rect(EST_X_OFFSET + (EST_WIDTH/3), EST_Y_OFFSET + (EST_HEIGHT/3),
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 6) {
      rect(EST_X_OFFSET + (2*EST_WIDTH/3), EST_Y_OFFSET + (EST_HEIGHT/3),
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 7) {
      rect(EST_X_OFFSET, EST_Y_OFFSET + (2*EST_HEIGHT/3),
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 8) {
      rect(EST_X_OFFSET + (EST_WIDTH/3), EST_Y_OFFSET + (2*EST_HEIGHT/3),
           EST_WIDTH/3, EST_HEIGHT/3);
    } else if (i == 9) {
      rect(EST_X_OFFSET + (2*EST_WIDTH/3), EST_Y_OFFSET + (2*EST_HEIGHT/3),
           EST_WIDTH/3, EST_HEIGHT/3);
    }
  }
}

public void fillSquare(int squareNum, int fillColor) {
  
  // Fill estimated square appropriately
  if (squareNum == 1) {
    fill(COLORS[0]);
    rect(EST_X_OFFSET, EST_Y_OFFSET,
         EST_WIDTH/3, EST_HEIGHT/3);
  } else if (squareNum == 2) {
    fill(COLORS[0]);
    rect(EST_X_OFFSET + (EST_WIDTH/3), EST_Y_OFFSET,
         EST_WIDTH/6, EST_HEIGHT/3);
    fill(COLORS[1]);
    rect(EST_X_OFFSET + (EST_WIDTH/2), EST_Y_OFFSET,
         EST_WIDTH/6, EST_HEIGHT/3);
  } else if (squareNum == 3) {
    fill(COLORS[1]);
    rect(EST_X_OFFSET + (2*EST_WIDTH/3), EST_Y_OFFSET,
         EST_WIDTH/3, EST_HEIGHT/3);
  } else if (squareNum == 4) {
    fill(COLORS[0]);
    rect(EST_X_OFFSET, EST_Y_OFFSET + (EST_HEIGHT/3),
         EST_WIDTH/3, EST_HEIGHT/6);
    fill(COLORS[2]);
    rect(EST_X_OFFSET, EST_Y_OFFSET + (EST_HEIGHT/2),
         EST_WIDTH/3, EST_HEIGHT/6);
  } else if (squareNum == 5) {
    // Middle square
    fill(COLORS[0]);
    rect(EST_X_OFFSET + (EST_WIDTH/3), EST_Y_OFFSET + (EST_HEIGHT/3),
         EST_WIDTH/6, EST_HEIGHT/6);
    fill(COLORS[1]);
    rect(EST_X_OFFSET + (EST_WIDTH/2), EST_Y_OFFSET + (EST_HEIGHT/3),
         EST_WIDTH/6, EST_HEIGHT/6);
    fill(COLORS[2]);
    rect(EST_X_OFFSET + (EST_WIDTH/3), EST_Y_OFFSET + (EST_HEIGHT/2),
         EST_WIDTH/6, EST_HEIGHT/6);
    fill(COLORS[3]);
    rect(EST_X_OFFSET + (EST_WIDTH/2), EST_Y_OFFSET + (EST_HEIGHT/2),
         EST_WIDTH/6, EST_HEIGHT/6);
  } else if (squareNum == 6) {
    fill(COLORS[1]);
    rect(EST_X_OFFSET + (2*EST_WIDTH/3), EST_Y_OFFSET + (EST_HEIGHT/3),
         EST_WIDTH/3, EST_HEIGHT/6);
    fill(COLORS[3]);
    rect(EST_X_OFFSET + (2*EST_WIDTH/3), EST_Y_OFFSET + (EST_HEIGHT/2),
         EST_WIDTH/3, EST_HEIGHT/6);
  } else if (squareNum == 7) {
    fill(COLORS[2]);
    rect(EST_X_OFFSET, EST_Y_OFFSET + (2*EST_HEIGHT/3),
         EST_WIDTH/3, EST_HEIGHT/3);
  } else if (squareNum == 8) {
    fill(COLORS[2]);
    rect(EST_X_OFFSET + (EST_WIDTH/3), EST_Y_OFFSET + (2*EST_HEIGHT/3),
         EST_WIDTH/6, EST_HEIGHT/3);
    fill(COLORS[3]);
    rect(EST_X_OFFSET + (EST_WIDTH/2), EST_Y_OFFSET + (2*EST_HEIGHT/3),
         EST_WIDTH/6, EST_HEIGHT/3);
  } else {
    fill(COLORS[3]);
    rect(EST_X_OFFSET + (2*EST_WIDTH/3), EST_Y_OFFSET + (2*EST_HEIGHT/3),
         EST_WIDTH/3, EST_HEIGHT/3);
  }
}

/*
public final float EST_X_OFFSET = 250.0;
public final float EST_Y_OFFSET = 350.0;
public final float EST_WIDTH = 400.0;
public final float EST_HEIGHT = 400.0;
*/