package gos.analysis.cdf;

import gov.nasa.gsfc.spdf.cdfj.CDFException;
import gov.nasa.gsfc.spdf.cdfj.TimeSeries;

public class DataArray extends DataTime {
  private double[][] values;

  public DataArray(TimeSeries ts) throws CDFException.ReaderError {
    this(ts.getTimes(), ts.getValues());
  }

  public DataArray(double[] times, Object values) {
    super(times);
    if (values instanceof double[][]) {
      this.values = (double[][])values;
    }
  }

  public double[][] getValues() {
    return this.values;
  }

  public double getValue(int first, int second) {
    return this.values[first][second];
  }

  @Override
  public boolean isEqualLength() {
    if (this.times != null && this.values != null) {
      return this.times.length == this.values.length;
    } else {
      return false;
    }
  }

  public int secondLength() {
    if (isEqualLength() && this.values.length > 0) {
      return this.values[0].length;
    } else {
      return -1;
    }
  }
}
