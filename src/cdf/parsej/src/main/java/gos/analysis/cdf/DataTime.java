package gos.analysis.cdf;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;

public abstract class DataTime {
  protected double[] times;

  public DataTime(double[] times) {
    this.times = times;
  }

  public double[] getTimes() {
    return this.times;
  }

  public double getTime(int index) {
    return this.times[index];
  }

  public abstract boolean isEqualLength();

  public int length() {
    if (isEqualLength()) {
      return this.times.length;
    } else {
      return -1;
    }
  }

  public static boolean areEqualLength(DataTime ...data) {
    if (data.length > 2) {
      for (int i = 1; i < data.length; i++) {
        if (data[i - 1].times.length != data[i].times.length) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  public static boolean areEqualLength(Map<String, DataTime> dataMap) {
    Set<String> keySet = dataMap.keySet();
    Iterator<String> it = keySet.iterator();
    if (dataMap.size() > 2) {
      String firstKey = it.next();
      while (it.hasNext()) {
        String secondKey = it.next();
        if (dataMap.get(firstKey).times.length != dataMap.get(secondKey).times.length) {
          return false;
        }
        firstKey = secondKey;
      }
      return true;
    } else {
      return false;
    }
  }

  public static boolean areEqualTimes(DataTime ...data) {
    if (areEqualLength(data)) {
      for (int i = 0; i < data[0].times.length; i++) {
        for (int j = 1; j < data.length; j++) {
          if (data[j - 1].times[i] != data[j].times[i]) {
            return false;
          }
        }
      }
      return true;
    } else {
      return false;
    }
  }

  public static boolean areEqualTimes(Map<String, DataTime> dataMap) {
    if (areEqualLength(dataMap)) {
      Set<String> keySet = dataMap.keySet();
      Iterator<String> it = keySet.iterator();
      String firstKey = it.next();
      while (it.hasNext()) {
        String secondKey = it.next();
        DataTime firstData = dataMap.get(firstKey);
        DataTime secondData = dataMap.get(secondKey);
        for (int i = 0; i < firstData.times.length; i++) {
          if (firstData.times[i] != secondData.times[i]) {
            return false;
          }
        }
        firstKey = secondKey;
      }
      return true;
    } else {
      return false;
    }
  }
}
