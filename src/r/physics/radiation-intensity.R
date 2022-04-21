# Inverse-square law for light and other electromagnetic radiation
# See https://en.wikipedia.org/wiki/Inverse-square_law

# Formula I = P/A = P/4*pi*r*r

# Example how powerful does a radio transmitter on Proxima Centauri
# need to be to detect a signal of 0.1W with a radio telescope with
# radius of 100 meter
Pant <- 0.1
Rant <- 100

# Distance to Proxima Centauri is 4.2465 ly and one ly is 9.46E12 km
# See https://en.wikipedia.org/wiki/Proxima_Centauri
Dpc <- 4.2465 * 9.46E12 * 1000 # converting the distance to m

# Aant = pi * Rant^2
Aant = pi * Rant * Rant

# Solving for P for the transmitter gives:
# Ptr = 4*pi*d^2 * Pant / Aant
Ptr = 4 * pi * Dpc * Dpc * Pant / Aant

# In Petawatt
Ptrpw = Ptr / 1E15
