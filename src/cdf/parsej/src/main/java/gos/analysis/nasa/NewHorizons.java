package gos.analysis.nasa;

import gos.analysis.cdf.Data;
import gos.analysis.cdf.DataArray;
import gos.analysis.cdf.Reading;
import gos.analysis.cdf.Writing;
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
import java.util.HashMap;
import java.util.Map;

public class NewHorizons {
  static final String NewHorizonsTrajectoryInputUrl = "https://spdf.gsfc.nasa.gov/pub/data/new-horizons/helio1day/new_horizons_helio1day_position_20060120_v01.cdf";
  static final String NewHorizonsTrajectoryOutputFile = "new_horizons_helio1day_position_20060120_v01.csv";
  static final String RadAu = "RAD_AU";
  static final String SeLat = "SE_LAT";
  static final String SeLon = "SE_LON";
  static final String HgLat = "HG_LAT";
  static final String HgLon = "HG_LON";
  static final String HgiLat = "HGI_LAT";
  static final String HgiLon = "HGI_LON";

  static final String NewHorizonsSwapIonsInputUrl = "https://spdf.gsfc.nasa.gov/pub/data/new-horizons/swap/ions/new_horizons_swap_pickup-ions_20081116180800_v1.0.1.cdf";
  static final String NewHorizonsSwapIonsOutputFile = "new_horizons_swap_pickup-ions_20081116180800_v1.0.1.csv";
  static final String Distance = "DISTANCE";
  static final String Density = "DENSITY";
  static final String Temperature = "TEMPERATURE";
  static final String Pressure = "PRESSURE";

  static final String NewHorizonsSwapValidSum2008InputUrl = "https://spdf.gsfc.nasa.gov/pub/data/new-horizons/swap/validsum/2008/new_horizons_swap_validsum_20081010210700_v1.0.5.cdf";
  static final String NewHorizonsSwapValidSum2008OutputFile = "new_horizons_swap_validsum_20081010210700_v1.0.5.csv";
  static final String StMet = "st_met";
  static final String SpMet = "sp_met";
  static final String N = "n";
  static final String V = "v";
  static final String T = "t";
  static final String Pdyn = "pdyn";
  static final String Pth = "pth";
  static final String NhHgiDX = "NH_HGI_D_X";
  static final String NhHgiDY = "NH_HGI_D_Y";
  static final String NhHgiDZ = "NH_HGI_D_Z";
  static final String NhHgiDLat = "NH_HGI_D_LAT";
  static final String NhHgiDR = "NH_HGI_D_R";
  static final String NhHgiDLon = "NH_HGI_D_LON";
  static final String NhHaeJ200DX = "NH_HAE_J2000_D_X";
  static final String NhHaeJ200DY = "NH_HAE_J2000_D_Y";
  static final String NhHaeJ200DZ = "NH_HAE_J2000_D_Z";
  static final String NhHaeJ200DLat = "NH_HAE_J2000_D_LAT";
  static final String NhHaeJ200DLon = "NH_HAE_J2000_D_LON";
  static final String NhHgDX = "NH_HG_D_X";
  static final String NhHgDY = "NH_HG_D_Y";
  static final String NhHgDZ = "NH_HG_D_Z";
  static final String NhHgDLat = "NH_HG_D_LAT";
  static final String NhHgDLon = "NH_HG_D_LON";
  static final String[] NewHorizonsSwapValidSum2008Variables = {
    StMet, SpMet, N, V, T, Pdyn, Pth, NhHgiDX, NhHgiDY, NhHgiDZ,
    NhHgiDLat, NhHgiDR, NhHgiDLon, NhHaeJ200DX, NhHaeJ200DY, NhHaeJ200DZ,
    NhHaeJ200DLat, NhHaeJ200DLon, NhHgDX, NhHgDY, NhHgDZ, NhHgDLat, NhHgDLon};
  static final String[] NewHorizonsSwapValidSum2008Headers = {
    "stmet", "spmet", "n", "v", "t", "pdyn", "pth", "nhhgidx", "nhhgidy", "nhhgidz",
    "nhhgidlat", "nhhgidr", "nhhgidlon", "nhhaej2000dx", "nhhaej2000dy", "nhhaej2000dz",
    "nhhaej2000dlat", "nhhaej2000dlon", "nhhgdx", "nhhgdy", "nhhgdz", "nhhgdlat", "nhhgdlon"
  };

  static final String NewHorizonsSwapIonsHistogramInputUrl = "https://spdf.gsfc.nasa.gov/pub/data/new-horizons/swap/ions-histogram/new_horizons_swap_pickup-ions-histogram_20081031180800_v1.0.1.cdf";
  static final String NewHorizonsSwapIonsHistogramOutputFile = "new_horizons_swap_pickup-ions-histogram_20081031180800_v1.0.1.csv";
  static final String NhSwapDistanceToSun = "nh_swap_distance_to_sun";
  static final String NhSwapHistogram = "nh_swap_histogram";
  static final String NhSwapHistogramUncertainties = "nh_swap_histogram_uncertainties";

  public static void ProcessNewHorizonsTrajectory() {
    String inputUrl = NewHorizonsTrajectoryInputUrl;
    String outputFile = NewHorizonsTrajectoryOutputFile;
    try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile))) {
      URL url = new URL(inputUrl);
      CDFReader reader = ReaderFactory.getReader(url);
      TimeSeries radauts = null;
      TimeSeries selatts = null, selonts = null;
      TimeSeries hglatts = null, hglonts = null;
      TimeSeries hgilatts = null, hgilonts = null;
      double[] radaut = null, radauv = null;
      double[] selatt = null, selont = null, selatv = null, selonv = null;
      double[] hglatt = null, hglont = null, hglatv = null, hglonv = null;
      double[] hgilatt = null, hgilont = null, hgilatv = null, hgilonv = null;
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
      if (reader.existsVariable(HgLat)) {
        hglatts = reader.getTimeSeries(HgLat);
        hglatt = hglatts.getTimes();
        length = Math.min(length, hglatt.length);
        hglatv = (double[])hglatts.getValues();
      }
      if (reader.existsVariable(HgLon)) {
        hglonts = reader.getTimeSeries(HgLon);
        hglont = hglonts.getTimes();
        length = Math.min(length, hglont.length);
        hglonv = (double[])hglonts.getValues();
      }
      if (reader.existsVariable(HgiLat)) {
        hgilatts = reader.getTimeSeries(HgiLat);
        hgilatt = hgilatts.getTimes();
        length = Math.min(length, hgilatt.length);
        hgilatv = (double[])hgilatts.getValues();
      }
      if (reader.existsVariable(HgiLon)) {
        hgilonts = reader.getTimeSeries(HgiLon);
        hgilont = hgilonts.getTimes();
        length = Math.min(length, hgilont.length);
        hgilonv = (double[])hgilonts.getValues();
      }

      if (radauts != null && selatts != null && selonts != null) {
        writer.write("time,rad,slat,slon,hglat,hglon,hgilat,hgilon");
        for (int i = 0; i < length; i++) {
          double rut = radaut[i];
          double slat = selatt[i];
          double slot = selont[i];
          double ruv = radauv[i];
          double slav = selatv[i];
          double slov = selonv[i];

          writer.newLine();
          if (Math.min(rut, Math.min(slat, slot)) == Math.max(rut, Math.max(slat, slot))) {
            writer.write(Double.toString(rut));
            writer.write(',');
            writer.write(Double.toString(ruv));
            writer.write(',');
            writer.write(Double.toString(slav));
            writer.write(',');
            writer.write(Double.toString(slov));
          } else {
            writer.write(",,,");
            System.err.println("Time mismatch for SE");
          }
          
          if (hglatts != null && hglonts != null) {
            double hglav = hglatv[i];
            double hglov = hglonv[i];
            writer.write(',');
            writer.write(Double.toString(hglav));
            writer.write(',');
            writer.write(Double.toString(hglov));
          } else {
            writer.write(",,");
            System.err.println("Time mismatch for HG");
          }

          if (hgilatts != null && hgilonts != null) {
            double hgilav = hgilatv[i];
            double hgilov = hgilonv[i];
            writer.write(',');
            writer.write(Double.toString(hgilav));
            writer.write(',');
            writer.write(Double.toString(hgilov));
          } else {
            writer.write(",,");
            System.err.println("Time mismatch for HGI");
          }
        }
      }
    } catch (MalformedURLException ex) {
      System.err.println("Generating URL from '" + inputUrl + "' failed: " + ex.getMessage());
    } catch (CDFException.ReaderError ex) {
      System.err.println("CDF Reader for '" + inputUrl + "' failed: " + ex.getMessage());
    } catch (IOException ex) {
      System.err.println("IO for '" + outputFile + "' failed: " + ex.getMessage());
    }
  }

  public static void ProcessNewHorizonsSwapIons() {
    String inputUrl = NewHorizonsSwapIonsInputUrl;
    String outputFile = NewHorizonsSwapIonsOutputFile;
    try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile))) {
      URL url = new URL(inputUrl);
      CDFReader reader = ReaderFactory.getReader(url);
      Data distanceData = null, densityData = null;
      Data temperatureData = null, pressureData = null;
      int length = Integer.MAX_VALUE;

      distanceData = Reading.ReadVariable(reader, Distance);
      length = Math.min(length, distanceData.length());
      densityData = Reading.ReadVariable(reader, Density);
      length = Math.min(length, densityData.length());
      temperatureData = Reading.ReadVariable(reader, Temperature);
      length = Math.min(length, temperatureData.length());
      pressureData = Reading.ReadVariable(reader, Pressure);
      length = Math.min(length, pressureData.length());

      if (length > 0 && Data.areEqualTimes(distanceData, densityData, temperatureData, pressureData)) {
        writer.write("time,distance,density,temperature,pressure");
        for (int i = 0; i < length; i++) {
          writer.newLine();
          writer.write(Double.toString(distanceData.getTime(i)));
          writer.write(',');
          writer.write(Double.toString(distanceData.getValue(i)));
          writer.write(',');
          writer.write(Double.toString(densityData.getValue(i)));
          writer.write(',');
          writer.write(Double.toString(temperatureData.getValue(i)));
          writer.write(',');
          writer.write(Double.toString(pressureData.getValue(i)));
        }
      } else {
        System.err.println("Time mismatch or error reading variables");
      }
    } catch (MalformedURLException ex) {
      System.err.println("Generating URL from '" + inputUrl + "' failed: " + ex.getMessage());
    } catch (CDFException.ReaderError ex) {
      System.err.println("CDF Reader for '" + inputUrl + "' failed: " + ex.getMessage());
    } catch (IOException ex) {
      System.err.println("IO for '" + outputFile + "' failed: " + ex.getMessage());
    }
  }

  public static boolean ProcessNewHorizonsSwapValidSum2008() {
    String inputUrl = NewHorizonsSwapValidSum2008InputUrl;
    String outputFile = NewHorizonsSwapValidSum2008OutputFile;
    String[] variables = NewHorizonsSwapValidSum2008Variables;
    String[] headers = NewHorizonsSwapValidSum2008Headers;
    try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile))) {
      URL url = new URL(inputUrl);
      CDFReader reader = ReaderFactory.getReader(url);
      Map<String, Data> dataMap = new HashMap<String, Data>();
      int length = Integer.MAX_VALUE;
      
      for (String variable : variables) {
        Data data = Reading.ReadVariable(reader, variable);
        if (data != null) {
          dataMap.put(variable, data);
          length = Math.min(length, data.length());
        } else {
          System.err.println("Failed to read variable '" + variable + "'");
          return false;
        }
      }
      
      if(length > 0 && Data.areEqualTimes(dataMap)) {
        Writing.WriteHeaderWithTime(writer, headers);
        for (int i = 0; i < length; i++) {
          writer.newLine();
          if (!Writing.WriteValuesWithTime(writer, variables, dataMap, i)) {
            System.err.println("Failed to write values");
            return false;
          }
        }
      }
    } catch (MalformedURLException ex) {
      System.err.println("Generating URL from '" + inputUrl + "' failed: " + ex.getMessage());
      return false;
    } catch (CDFException.ReaderError ex) {
      System.err.println("CDF Reader for '" + inputUrl + "' failed: " + ex.getMessage());
      return false;
    } catch (IOException ex) {
      System.err.println("IO for '" + outputFile + "' failed: " + ex.getMessage());
      return false;
    }
    return true;
  }

  public static boolean ProcessNewHorizonsSwapIonsHistogram() {
    String inputUrl = NewHorizonsSwapIonsHistogramInputUrl;
    String outputFile = NewHorizonsSwapIonsHistogramOutputFile;
    try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile))) {
      URL url = new URL(inputUrl);
      CDFReader reader = ReaderFactory.getReader(url);
      int length = Integer.MAX_VALUE;

      Data distanceData = Reading.ReadVariable(reader, NhSwapDistanceToSun);
      if (distanceData != null) {
        length = Math.min(length, distanceData.length());
      } else {
        System.err.println("Failed to read 'Distance to Sun' variable");
        return false;
      }

      DataArray histogramDataArray = Reading.ReadVariableArray(reader, NhSwapHistogram);
      if (histogramDataArray != null) {
        length = Math.min(length, histogramDataArray.length());
      } else {
        System.err.println("Failed to read 'Histogram' variable");
        return false;
      }

      DataArray histogramUncertaintiesDataArray = Reading.ReadVariableArray(reader, NhSwapHistogramUncertainties);
      if (histogramUncertaintiesDataArray != null) {
        length = Math.min(length, histogramUncertaintiesDataArray.length());
      } else {
        System.err.println("Failed to read 'Histogram Uncertainties' variable");
        return false;
      }

      if (length > 0 && Data.areEqualTimes(distanceData, histogramDataArray, histogramUncertaintiesDataArray)) {
        int secondLength = histogramDataArray.secondLength();
        writer.write("time,distance");
        Writing.WriteHeaderArray(writer, "hist", secondLength);
        Writing.WriteHeaderArray(writer, "unce", secondLength);
        for (int i = 0; i < length; i++) {
          writer.newLine();
          writer.write(Double.toString(distanceData.getTime(i)));
          writer.write(',');
          writer.write(Double.toString(distanceData.getValue(i)));
          for (int j = 0; j < secondLength; j++) {
            writer.write(',');
            writer.write(Double.toString(histogramDataArray.getValue(i, j)));
          }
          for (int j = 0; j < secondLength; j++) {
            writer.write(',');
            writer.write(Double.toString(histogramUncertaintiesDataArray.getValue(i, j)));
          }
        }
      } else {
        System.err.println("Time mismatch");
        return false;
      }
    } catch (MalformedURLException ex) {
      System.err.println("Generating URL from '" + inputUrl + "' failed: " + ex.getMessage());
      return false;
    } catch (CDFException.ReaderError ex) {
      System.err.println("CDF Reader for '" + inputUrl + "' failed: " + ex.getMessage());
      return false;
    } catch (IOException ex) {
      System.err.println("IO for '" + outputFile + "' failed: " + ex.getMessage());
      return false;
    }
    return true;
  }
}
