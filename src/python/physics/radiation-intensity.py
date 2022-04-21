import math

# Inverse-square law for light and other electromagnetic radiation
# See https://en.wikipedia.org/wiki/Inverse-square_law

# Formula I = P/A = P/4*pi*r*r

# Example how powerful does a radio transmitter on Proxima Centauri
# need to be to detect a signal of 0.1W with a radio telescope with
# radius of 100 meter
pant = 0.1
rant = 100

# Distance to Proxima Centauri is 4.2465 ly and one ly is 9.46E12 km
# See https://en.wikipedia.org/wiki/Proxima_Centauri
dpc = 4.2465 * 9.46E12 * 1000 # converting the distance to m

# Aant = pi * Rant^2
aant = math.pi * rant * rant

# Solving for P for the transmitter gives:
# Ptr = 4*pi*d^2 * Pant / Aant
ptr = 4 * math.pi * dpc * dpc * pant / aant

# In Petawatt
ptrpw = ptr / 1E15
print("Transmitter power needs to be %f Petawatts" % ptrpw)
