import java.lang.Comparable;
public class DataIndexPair implements Comparable<DataIndexPair> {
 
  public float data;
  public int index;
  
  public DataIndexPair(float data, int index) { 
    this.data = data;
    this.index = index;
  }
  
  public int compareTo(DataIndexPair o) {
    if (data == o.data) {
      return 0;
    } else if (data > o.data) {
      return 1;
    }
    return -1;
  }
}