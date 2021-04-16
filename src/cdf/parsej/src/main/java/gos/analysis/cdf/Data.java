package gos.analysis.cdf;

import gov.nasa.gsfc.spdf.cdfj.CDFException;
import gov.nasa.gsfc.spdf.cdfj.TimeSeries;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;

public class Data extends DataTime {
  private double[] values;

  public Data(TimeSeries ts) throws CDFException.ReaderError {
    this(ts.getTimes(), ts.getValues());
  }

  public Data(double[] times, Object values) {
    super(times);
    if (values instanceof double[]) {
      this.values = (double[])values;
    }
  }

  public double[] getValues() {
    return this.values;
  }

  public double getValue(int index) {
    return this.values[index];
  }

  @Override
  public boolean isEqualLength() {
    if (this.times != null && this.values != null) {
      return this.times.length == this.values.length;
    } else {
      return false;
    }
  }

  public static boolean areEqualLength(Map<String, Data> dataMap) {
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

  public static boolean areEqualTimes(Map<String, Data> dataMap) {
    if (areEqualLength(dataMap)) {
      Set<String> keySet = dataMap.keySet();
      Iterator<String> it = keySet.iterator();
      String firstKey = it.next();
      while (it.hasNext()) {
        String secondKey = it.next();
        Data firstData = dataMap.get(firstKey);
        Data secondData = dataMap.get(secondKey);
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
