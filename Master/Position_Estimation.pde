// Constants
public final float EST_X_OFFSET = 250.0;
public final float EST_Y_OFFSET = 350.0;
public final float EST_WIDTH = 400.0;
public final float EST_HEIGHT = 400.0;
public final int HYSTERESIS_MAX_COUNT = 3;
public final float CLOSE_THRESH = 0.05;
public final float FAR_THRESH = 0.15;

// Non-constants
public int new_estimate_hysteresis;
public int last_square_est;
public int official_est;
public int hysteresis_count;

// Various initialization
public void initPositionEstimation() {
  new_estimate_hysteresis = millis();
  official_est = 1;
  hysteresis_count = 0;
  last_square_est = 1;
  drawEstimationGrid();
}

// Update the estimated position, using a simple hysteresis technique (counting)
public void updatePositionEstimate(float[] voltages) {
  // Get array index of max pin voltage
  int index = indexOfMaxPinVoltage(voltages);
  // Get current estimate based on this round of pin voltages
  int square = getCurrentEstimate(index, voltages);
  // Decide whether or not to change the official position estimate
  //if (validEstimate(square)) {
    newEstimate(square, COLORS[index]);
  //}
}

// Determine whether the current estimate should be reflected as the official estimate.
// Uses a simple hysteresis counter to only update the official estimate after the
// same position has been estimated for HYSTERESIS_MAX_COUNT times.
public boolean validEstimate(int square_est) {
  boolean valid = false;
  if (square_est != official_est) {
    // Increment the hysteresis counter if we receive the same estimate
    // that we just had (but is different from the official estimate.
    // Otherwise, reset the hysteresis counter to 0
    if (square_est == last_square_est) {
      hysteresis_count += 1;
      if (hysteresis_count == HYSTERESIS_MAX_COUNT) {
        println("Changing estimate to " + square_est);
        // Change the official position estimate
        official_est = square_est;
        hysteresis_count = 0;
        valid = true;
      } else {
        println("Count incremented, but not at threshold count value.");
      }
    } else {
      println("New different estimate, resetting count to 1");
      hysteresis_count = 1;
    }
    
    last_square_est = square_est;
  } else {
    hysteresis_count = 0;
  }
  
  return valid;
}

// Computes the current square estimated from the antenna pin voltages
public int getCurrentEstimate(int max_index, float[] voltages) {
  // Compare the difference in magnitude between other pin voltages
  // This will tell you whether the estimate should be in a node's region,
  //   or in between the regions of two nodes
  ArrayList<DataIndexPair> differences = new ArrayList<DataIndexPair>();
  
  int numCloseNodes = 0,
      numFarNodes = 0,
      squareEstimate = 0;
  for (int i = 0; i < NUM_CLIENTS; i += 1) {
    if (i == max_index) {
      differences.add(new DataIndexPair(0.0, i));
    } else {
      float cur_diff = voltages[max_index] - voltages[i];
      differences.add(new DataIndexPair(cur_diff, i));
      if (cur_diff < CLOSE_THRESH) {
        numCloseNodes += 1;
      } else if (cur_diff > FAR_THRESH) {
        numFarNodes += 1;
      }
    }
  }
  
  // Sort ascending order
  //IndexComparator comp = new IndexComparator();
  java.util.Collections.sort(differences);
  
  
  if (differences.get(1).data < CLOSE_THRESH) {
    if (differences.get(2).data < CLOSE_THRESH) {
      if (differences.get(3).data < CLOSE_THRESH) {
        // Middle
        println("Middle");
        squareEstimate = 5;
      } else {
        // Middle or corner
        println("Weird case, defaulting to middle");
        squareEstimate = 5;
      }
    } else {
      // Between
      println(differences.get(0).index);
      println("Between " + max_index + " and " + differences.get(1).index);
      squareEstimate = transitionRegionBetween(max_index, differences.get(1).index);
    }
  } else {
    // Node with max voltage
    println("Right on " + max_index);
    squareEstimate = squareWithNode(max_index);
  }
  
  
  /*
  if (numFarNodes == 3) {
    // Estimate is the region which contains the node with the max pin voltage
    squareEstimate = squareWithNode(max_index);
    println("3 far ");
  } else if (numFarNodes == 2) {
    println("2 far ");
    // Estimate is the region between one of the two other nodes
    int[] oppositeNodeIndices = indicesOfOpposites(max_index);
    boolean found = false;
    for (int i = 0; i < oppositeNodeIndices.length; i += 1) {
      if (voltages[max_index] - voltages[oppositeNodeIndices[i]] < CLOSE_THRESH) {
        // Estimate is the region between these two nodes
        squareEstimate = transitionRegionBetween(max_index, oppositeNodeIndices[i]);
        found = true;
      }
    }
    if (!found) {
      squareEstimate = squareWithNode(max_index);
    }
  } else {
    // Estimate center node
    squareEstimate = 5;
    print("three");
  }
  */
  
  println(squareEstimate);
  return squareEstimate;
}

// Return the square index corresponding to the
// antenna node index given
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

// Return the square index of the transition region corresponding
// to the two antenna indices given
public int transitionRegionBetween(int temp1, int temp2) {
  int indx1, indx2;
  if (temp1 > temp2) {
    indx1 = temp2;
    indx2 = temp1;
  } else {
    indx1 = temp1;
    indx2 = temp2;
  }

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

// Return the antenna index with the highest antenna
// pin voltage.
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

// Return the antenna indices of the squares that are
// opposite from the antenna index given.
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

// Update the official estimate, and reflect this in
// the displayed grid
public void newEstimate(int squareNum, int fillColor) {
  clearSquares();
  fillSquare(squareNum, fillColor);
  drawEstimationGrid();
}

// Redraw the position estimation grid
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

// Clear the display of all square for re-display purposes
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

// Fill the given square with the given color.
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
public void assessCurrentEstimate(int temp_estimate) {
  if (temp_estimate != official_est) {
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