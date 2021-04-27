package gos.analysis.nasa;

import gos.analysis.cdf.Data;
import gos.analysis.cdf.DataArray;
import gos.analysis.cdf.DataTime;
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

public class SolarOrbiter {
  static final String SolarOrbiterTrajectoryOutputFile = "solo_helio1day_position_20200211_v01.csv";
  static final String CdfUrl = "https://spdf.gsfc.nasa.gov/pub/data/solar-orbiter/helio1day/solo_helio1day_position_20200211_v01.cdf";
  static final String RadAu = "RAD_AU";
  static final String SeLat = "SE_LAT";
  static final String SeLon = "SE_LON";

  static final String SolarOrbiterSwaL1EasObpmOutputPath = "..\\..\\..\\tmp\\nasa\\spdf\\solar-orbiter\\swa\\science\\l1\\eas-onbpartmoms\\2020\\";
  static final String SolarOrbiterSwaL1EasObpmOutputFile = "solo_l1_swa-eas-onbpartmoms.csv";
  static final String SolarOrbiterSwaL1EasObpmPath = "https://spdf.gsfc.nasa.gov/pub/data/solar-orbiter/swa/science/l1/eas-onbpartmoms/2020/";
  static final String[] SolarOrbiterSwaL1EasObpmFiles = {
    "solo_l1_swa-eas-onbpartmoms_20200615t144826-20200615t175346_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200615t175350-20200616t175346_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200616t175350-20200617t175347_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200617t175351-20200618t175347_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200618t175351-20200619t175347_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200619t175351-20200620t175347_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200620t175351-20200621t235831_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200622t110507-20200622t175347_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200623t050031-20200623t175347_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200624t050028-20200624t175348_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200625t050028-20200625t175348_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200626t050028-20200626t175348_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200627t050028-20200627t175348_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200628t161908-20200628t175348_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200720t110527-20200720t235955_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200720t235959-20200721t235955_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200721t235959-20200722t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200722t235956-20200723t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200723t235956-20200724t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200724t235956-20200725t234500_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200725t234500-20200726t235812_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200727t110512-20200727t235948_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200727t235952-20200728t235948_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200728t235952-20200729t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200729t235953-20200730t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200730t235953-20200731t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200731t235953-20200801t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200801t235953-20200802t235813_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200803t110713-20200803t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200803t235953-20200804t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200804t235953-20200805t235906_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200807t153234-20200807t235954_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200807t235958-20200808t235954_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200808t235958-20200809t235814_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200811t101210-20200811t235954_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200811t235958-20200812t235955_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200812t235959-20200813t231915_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200819t154404-20200819t235956_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200820t000000-20200820t235904_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200827t142205-20200827t235953_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200827t235957-20200828t235953_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200828t235957-20200829t235953_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200829t235957-20200830t235813_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200831t110713-20200831t235953_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200831t235957-20200901t235953_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200901t235957-20200902t235953_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200902t235957-20200903t235954_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200903t235958-20200904t235954_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200904t235958-20200905t235954_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200905t235958-20200906t235346_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200914t110943-20200914t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200914t235955-20200915t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200915t235955-20200916t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200916t235955-20200917t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200917t235956-20200918t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200918t235956-20200919t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200919t235956-20200920t235812_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200920t235816-20200922t235948_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200922t235952-20200923t235948_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200923t235952-20200924t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200924t235953-20200925t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200925t235953-20200926t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200926t235953-20200927t235813_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200928t110513-20200928t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200928t235953-20200929t235949_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20200929t235953-20200930t122605_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201002t111746-20201002t235950_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201002t235954-20201003t235950_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201003t235954-20201004t235814_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201005t110510-20201005t210538_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201006t181714-20201006t193650_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201007t094546-20201007t235950_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201007t235954-20201008t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201008t235955-20201009t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201009t235955-20201010t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201010t235955-20201011t235815_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201012t100511-20201012t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201012t235955-20201013t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201013t235955-20201014t235951_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201014t235955-20201015t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201015t235956-20201016t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201016t235956-20201017t235952_v01.cdf",
    "solo_l1_swa-eas-onbpartmoms_20201017t235956-20201018t235812_v01.cdf"
  };
  static final String SwaEasScPotential = "SWA_EAS_SCPotential";
  static final String SwaEasOnlyLowEneN = "SWA_EAS1_only_Low_Ene_N";
  static final String SwaEasOnlyLowEneV = "SWA_EAS1_only_Low_Ene_V";
  static final String SwaEasOnlyLowEneP = "SWA_EAS1_only_Low_Ene_P";
  static final String SwaEasOnlyLowEneH = "SWA_EAS1_only_Low_Ene_H";
  static final String SwaEasOnlyCoreHaloN = "SWA_EAS1_only_Core_Halo_N";
  static final String SwaEasOnlyCoreHaloV = "SWA_EAS1_only_Core_Halo_V";
  static final String SwaEasOnlyCoreHaloP = "SWA_EAS1_only_Core_Halo_P";
  static final String SwaEasOnlyCoreHaloH = "SWA_EAS1_only_Core_Halo_H";
  static final String SwaEasOnlyStrahlN = "SWA_EAS1_only_Strahl_N";
  static final String SwaEasOnlyStrahlV = "SWA_EAS1_only_Strahl_V";
  static final String SwaEasOnlyStrahlP = "SWA_EAS1_only_Strahl_P";
  static final String SwaEasOnlyStrahlH = "SWA_EAS1_only_Strahl_H";

  static final String[] SolarOrbiterSwaL1EasObpmVariables = {
    SwaEasScPotential,
    SwaEasOnlyLowEneN, SwaEasOnlyLowEneV, SwaEasOnlyLowEneP, SwaEasOnlyLowEneH,
    SwaEasOnlyCoreHaloN, SwaEasOnlyCoreHaloV, SwaEasOnlyCoreHaloP, SwaEasOnlyCoreHaloH
  };
  static final Map<String, String> SolarOrbiterSwaL1EasObpmHeaders = Map.ofEntries(
    Map.entry(SwaEasScPotential, "SCPotential"),
    Map.entry(SwaEasOnlyLowEneN, "OnlyLowEneN"),
    Map.entry(SwaEasOnlyLowEneV, "OnlyLowEneV"),
    Map.entry(SwaEasOnlyLowEneP, "OnlyLowEneP"),
    Map.entry(SwaEasOnlyLowEneH, "OnlyLowEneH"),
    Map.entry(SwaEasOnlyCoreHaloN, "OnlyCoreHaloN"),
    Map.entry(SwaEasOnlyCoreHaloV, "OnlyCoreHaloV"),
    Map.entry(SwaEasOnlyCoreHaloP, "OnlyCoreHaloP"),
    Map.entry(SwaEasOnlyCoreHaloH, "OnlyCoreHaloH"),
    Map.entry(SwaEasOnlyStrahlN, "OnlyStrahN"),
    Map.entry(SwaEasOnlyStrahlV, "OnlyStrahV"),
    Map.entry(SwaEasOnlyStrahlP, "OnlyStrahP"),
    Map.entry(SwaEasOnlyStrahlH, "OnlyStrahH")
  );
  static final Map<String, Integer> SolarOrbiterSwaL1EasObpmVariableChannels = Map.ofEntries(
    Map.entry(SwaEasScPotential, 1),
    Map.entry(SwaEasOnlyLowEneN, 1),
    Map.entry(SwaEasOnlyLowEneV, 3),
    Map.entry(SwaEasOnlyLowEneP, 6),
    Map.entry(SwaEasOnlyLowEneH, 3),
    Map.entry(SwaEasOnlyCoreHaloN, 1),
    Map.entry(SwaEasOnlyCoreHaloV, 3),
    Map.entry(SwaEasOnlyCoreHaloP, 6),
    Map.entry(SwaEasOnlyCoreHaloH, 3),
    Map.entry(SwaEasOnlyStrahlN, 1),
    Map.entry(SwaEasOnlyStrahlV, 3),
    Map.entry(SwaEasOnlyStrahlP, 6),
    Map.entry(SwaEasOnlyStrahlH, 3)
  );

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

  public static boolean ProcessSolarOrbiterSwaL1EasObpm() {
    String currentUrl = "";
    String outputFile = SolarOrbiterSwaL1EasObpmOutputFile;
    String outputFilePath = SolarOrbiterSwaL1EasObpmOutputPath + outputFile;
    String[] variables = SolarOrbiterSwaL1EasObpmVariables;
    Map<String, String> headers = SolarOrbiterSwaL1EasObpmHeaders;
    Map<String, Integer> channels = SolarOrbiterSwaL1EasObpmVariableChannels;
    try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFilePath))) {
      Writing.WriteHeaderWithTimeAndChannels(writer, variables, headers, channels);
      for (String file : SolarOrbiterSwaL1EasObpmFiles) {
        currentUrl = SolarOrbiterSwaL1EasObpmPath + file;
        URL url = new URL(currentUrl);
        CDFReader reader = ReaderFactory.getReader(url);
        Map<String, DataTime> dataMap = new HashMap<String, DataTime>();
        int length = Integer.MAX_VALUE;

        for (String variable : variables) {
          DataTime data = null;
          Integer count = null;
          if (channels.containsKey(variable)) {
            count = channels.get(variable);
          }
          if (count != null && count > 1) {
            data = Reading.ReadVariableArray(reader, variable);
          } else {
            data = Reading.ReadVariable(reader, variable);
          }
          if (data != null) {
            dataMap.put(variable, data);
            length = Math.min(length, data.length());
          } else {
            System.err.println("Failed to read variable '" + variable + "'");
            return false;
          }
        }

        if (length > 0) {
          if (DataTime.areEqualTimes(dataMap)) {
            for (int i = 0; i < length; i++) {
              writer.newLine();
              Writing.WriteValuesWithDataTime(writer, variables, dataMap, i);
            }
          } else {
            System.err.println("File '" + file + "' has unequal times");
          }
        } else {
          System.err.println("File '" + file + "' parsed to zero length");
        }
        System.out.print('.');
      }
      System.out.println("Completed");
    }
    catch (MalformedURLException ex) {
      System.err.println("Generating URL from '" + currentUrl + "' failed: " + ex.getMessage());
      return false;
    } catch (CDFException.ReaderError ex) {
      System.err.println("CDF Reader for '" + currentUrl + "' failed: " + ex.getMessage());
      return false;
    } catch (IOException ex) {
      System.err.println("IO for '" + outputFile + "' failed: " + ex.getMessage());
      return false;
    }
    return true;
  }
}
