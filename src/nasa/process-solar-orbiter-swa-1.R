# Process NASA Solar Orbiter Solar Wind Plasma Analyser (SWA) data
#
#

# Dependencies
library(data.table)

# Aggregate data.frame Function
aggregatedf <- function(df, n = 5, FUN = mean) {
  aggregate(df,
          by = list(gl(ceiling(nrow(df)/n), n)[1:nrow(df)]),
          FUN = FUN)[-1]
}

# Read Data

# Read Trajectory data
traj <- read.csv('tmp/nasa/spdf/solar-orbiter/helio1day/solo_helio1day_position_20200211_v01.csv')

# Read SWA data
df <- read.csv('tmp/nasa/spdf/solar-orbiter/swa/science/l1/eas-onbpartmoms/2020/solo_l1_swa-eas-onbpartmoms.csv')

# Aggregate by mean
df <- aggregatedf(df, n = 100)

# Convert to data tables
setDT(traj)
setDT(df)

# Combine data
setkey(traj, time)
setkey(df, time)
dftraj <- traj[df, roll = "nearest"]
