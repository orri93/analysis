package gos.analysis.org;

import java.net.MalformedURLException;
import java.net.URL;

import gov.nasa.gsfc.spdf.cdfj.CDFReader;
import gov.nasa.gsfc.spdf.cdfj.ReaderFactory;
import gov.nasa.gsfc.spdf.cdfj.CDFException.ReaderError;
import gov.nasa.gsfc.spdf.cdfj.TimeSeries;

/**
 * Hello world!
 */
public final class App {
  static final String CdfUrl = "https://spdf.gsfc.nasa.gov/pub/data/solar-orbiter/helio1day/solo_helio1day_position_20200211_v01.cdf";
  static final String RadAu = "RAD_AU";
  static final String SeLat = "SE_LAT";
  static final String SeLon = "SE_LON";

  /**
   * Says hello to the world.
   * @param args The arguments of the program.
   */
  public static void main(String[] args) {
    try {
      URL url = new URL(CdfUrl);
      CDFReader reader = ReaderFactory.getReader(url);
      TimeSeries radauts = null;
      TimeSeries selatts = null;
      TimeSeries selonts = null;
      double[] radaut = null;
      double[] selatt = null;
      double[] selont = null;
      double[] radauv = null;
      double[] selatv = null;
      double[] selonv = null;
      int length = Integer.MAX_VALUE;

      if (reader.existsVariable(RadAu)) {
        radauts = reader.getTimeSeries(RadAu);
        radaut = radauts.getTimes();
        length = Math.min(length, radaut.length);
        radauv = (double[])radauts.getValues();
      }
      if (reader.existsVariable(SeLat)) {
        selatts = reader.getTimeSeries(SeLat);
        selatt = selatts.getTimes();
        length = Math.min(length, selatt.length);
        selatv = (double[])selatts.getValues();
      }
      if (reader.existsVariable(SeLon)) {
        selonts = reader.getTimeSeries(SeLon);
        selont = selonts.getTimes();
        length = Math.min(length, selont.length);
        selonv = (double[])selonts.getValues();
      }

      if (radauts != null && selatts != null && selonts != null) {
        for (int i = 0; i < length; i++) {
          double rut = radaut[i];
          double slat = selatt[i];
          double slot = selont[i];
          double ruv = radauv[i];
          double slav = selatv[i];
          double slov = selonv[i];
          if (Math.min(rut, Math.min(slat, slot)) == Math.max(rut, Math.max(slat, slot))) {
            System.out.println(
              Double.toString(rut) + "," +
              Double.toString(ruv) + "," +
              Double.toString(slav) + "," +
              Double.toString(slov));
          } else {
            System.err.println("Time mismatch");
          }
        }
      }

    } catch (MalformedURLException ex) {
      System.err.println("Generating URL from '" + CdfUrl + "' failed: " + ex.getMessage());
    } catch (ReaderError ex) {
      System.err.println("CDF Reader for '" + CdfUrl + "' failed: " + ex.getMessage());
    }
  }
}
