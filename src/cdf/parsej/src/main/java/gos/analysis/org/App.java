package gos.analysis.org;

import gos.analysis.nasa.NewHorizons;
import gos.analysis.nasa.SolarOrbiter;

/**
 * Hello world!
 */
public final class App {
  public static void main(String[] args) {
    // SolarOrbiter.ProcessSolarOrbiterTrajectory();
    SolarOrbiter.ProcessSolarOrbiterSwaL1EasObpm();
    // NewHorizons.ProcessNewHorizonsTrajectory();
    // NewHorizons.ProcessNewHorizonsSwapIons();
    NewHorizons.ProcessNewHorizonsSwapValidSum2008();
    // NewHorizons.ProcessNewHorizonsSwapIonsHistogram();
  }
}
