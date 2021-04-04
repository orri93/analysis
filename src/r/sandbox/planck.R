# Planck's law
# See https://en.wikipedia.org/wiki/Planck's_law
#

# Planck's law describes the spectral density of electromagnetic radiation
# emitted by a black body in thermal equilibrium at a given temperature T, when
# there is no net flow of matter or energy between the body and its environment

# Dependencies
library(Rmpfr)

pb <- 128

# Boltzmann constant in J/K
k <- mpfr("1.380649E-23", pb)

# Planck constant in Js
h <- mpfr("6.62607015E-34", pb)

# Speed of light in m/s
c <- mpfr("299792458", pb)

t <- mpfr("5000", pb)
lambda <- mpfr("5E-7", pb)

et <- h * c / lambda * k * t
Bf <- mpfr("1", pb) / exp(et) - mpfr("1", pb) 
Bt <- mpfr("2", pb) * h * c * c / (lambda ^ mpfr("5", pb))

magnitude = mpfr("1E6", pb)
maxwavelength = mpfr("2", pb) / magnitude
wavelengthstep = mpfr("0.02", pb) / magnitude
wavelength <- seq(wavelengthstep, maxwavelength, wavelengthstep)

eta <- h * c / wavelength * k * t
Bfa <- mpfr("1", pb) / exp(et) - mpfr("1", pb)
Bta <- mpfr("2", pb) * h * c * c / (wavelength ^ mpfr("5", pb))

distribution = Bfa * Bta

plot(wavelength, distribution)
