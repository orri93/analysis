package gos.analysis.cdf;

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
}
