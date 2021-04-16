package gos.analysis.cdf;

import gov.nasa.gsfc.spdf.cdfj.CDFException;
import gov.nasa.gsfc.spdf.cdfj.CDFReader;
import gov.nasa.gsfc.spdf.cdfj.TimeSeries;

public class Reading {
  public static Data ReadVariable(
    CDFReader reader,
    String variable) throws CDFException.ReaderError {
    if (reader.existsVariable(variable)) {
      TimeSeries ts = reader.getTimeSeries(variable);
      if (ts != null) {
        return new Data(ts);
      }
    }
    return null;
  }

  public static DataArray ReadVariableArray(
    CDFReader reader,
    String variable) throws CDFException.ReaderError {
      if (reader.existsVariable(variable)) {
        TimeSeries ts = reader.getTimeSeries(variable);
        if (ts != null) {
          return new DataArray(ts);
        }
      }
    return null;
  }
}
