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
}
