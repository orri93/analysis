package gos.analysis.nasa;

import gov.nasa.gsfc.spdf.cdfj.CDFException;
import gov.nasa.gsfc.spdf.cdfj.CDFReader;
import gov.nasa.gsfc.spdf.cdfj.ReaderFactory;
import gov.nasa.gsfc.spdf.cdfj.TimeSeries;

import java.io.BufferedWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;

public class SolarOrbiter {
  static final String SolarOrbiterTrajectoryOutputFile = "solo_helio1day_position_20200211_v01.csv";
  static final String CdfUrl = "https://spdf.gsfc.nasa.gov/pub/data/solar-orbiter/helio1day/solo_helio1day_position_20200211_v01.cdf";
  static final String RadAu = "RAD_AU";
  static final String SeLat = "SE_LAT";
  static final String SeLon = "SE_LON";

  public static void ProcessSolarOrbiterTrajectory() {
    try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(SolarOrbiterTrajectoryOutputFile))) {
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
        writer.write("time,rad,lat,lon");
        for (int i = 0; i < length; i++) {
          double rut = radaut[i];
          double slat = selatt[i];
          double slot = selont[i];
          double ruv = radauv[i];
          double slav = selatv[i];
          double slov = selonv[i];
          if (Math.min(rut, Math.min(slat, slot)) == Math.max(rut, Math.max(slat, slot))) {
            writer.newLine();
            writer.write(Double.toString(rut));
            writer.write(',');
            writer.write(Double.toString(ruv));
            writer.write(',');
            writer.write(Double.toString(slav));
            writer.write(',');
            writer.write(Double.toString(slov));
          } else {
            System.err.println("Time mismatch");
          }
        }
      }
      writer.flush();
      writer.close();
    } catch (MalformedURLException ex) {
      System.err.println("Generating URL from '" + CdfUrl + "' failed: " + ex.getMessage());
    } catch (CDFException.ReaderError ex) {
      System.err.println("CDF Reader for '" + CdfUrl + "' failed: " + ex.getMessage());
    } catch (IOException ex) {
      System.err.println("IO for '" + SolarOrbiterTrajectoryOutputFile + "' failed: " + ex.getMessage());
    }
  }
}
