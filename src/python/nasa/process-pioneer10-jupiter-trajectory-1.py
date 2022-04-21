# Process NASA Pioneer 10 Jupiter Trajectory data
#

# Dependencies
from matplotlib.pyplot import axis
import pandas as pd
import datetime as dt
import numpy as np

# Download Data

# Download Trajectory data
# Format information see
# https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/traj/jupiter/p10trjjup_fmt.txt
rtraj_path = "https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/traj/jupiter/p10trjjup.asc"
col_names = ['year', 'fdoy', 'srange', 'seclat', 'seclon', 'prange', 'peqlat', 'peqlon']
rtraj = pd.read_csv(rtraj_path, delim_whitespace=True, names=col_names, dtype=float)

# Fix date
rtraj['ts'] = rtraj.apply(lambda row: dt.date(int(row['year']), 1, 1) + dt.timedelta(seconds=86400 * row['fdoy']), axis=1)

print(rtraj)
