package gos.analysis.cdf;

import java.io.IOException;
import java.io.Writer;
import java.util.Map;

public class Writing {
  public static void WriteHeaderWithTime(
    Writer writer,
    String[] headers) throws IOException {
    writer.write("time");
    for (int i = 0; i < headers.length; i++) {
      writer.write(',');
      writer.write(headers[i]);
    }
  }

  public static void WriteHeaderWithTimeAndChannels(
    Writer writer,
    String[] variables,
    Map<String, String> headers,
    Map<String, Integer> channels) throws IOException {
    writer.write("time");
    for (int i = 0; i < variables.length; i++) {
      String variable = variables[i];
      String header = headers.get(variable);
      Integer count = null;
      if (channels.containsKey(variable)) {
        count = channels.get(variable);
      }
      if (count != null && count.intValue() > 1) {
        for (int j = 0; j < count.intValue(); j++) {
          writer.write(',');
          writer.write(header + Integer.toString(j));  
        }
      } else {
        writer.write(',');
        writer.write(header);  
      }
    }
  }

  public static void WriteHeaderArray(
    Writer writer,
    String header,
    int length) throws IOException {
      for (int i = 1; i <= length; i++) {
        writer.write(',');
        writer.write(header);
        writer.write(Integer.toString(i));
      }
    }

  public static boolean WriteValuesWithTime(
    Writer writer,
    String[] variables,
    Map<String, Data> dataMap,
    int index) throws IOException {
    for (int i = 0; i < variables.length; i++) {
      Data data = dataMap.get(variables[i]);
      if (data != null) {
        if (i == 0) {
          writer.write(Double.toString(data.getTime(index)));
        }
        writer.write(',');
        writer.write(Double.toString(data.getValue(index)));
      } else {
        return false;
      }
    }
    return true;
  }

  public static boolean WriteValuesWithDataTime(
    Writer writer,
    String[] variables,
    Map<String, DataTime> dataMap,
    int index) throws IOException {
    for (int i = 0; i < variables.length; i++) {
      String variable = variables[i];
      DataTime dataTime = dataMap.get(variable);
      if (dataTime != null) {
        if (i == 0) {
          writer.write(Double.toString(dataTime.getTime(index)));
        }
        if (dataTime instanceof DataArray) {
          DataArray dataArray = (DataArray)dataTime;
          int secondLength = dataArray.secondLength();
          for (int j = 0; j < secondLength; j++) {
            writer.write(',');
            writer.write(Double.toString(dataArray.getValue(index, j)));
          }
        } else if (dataTime instanceof Data) {
          Data data = (Data)dataTime;
          writer.write(',');
          writer.write(Double.toString(data.getValue(index)));
        }
      }
    }
    return true;
  }
}
