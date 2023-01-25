# Dependencies
library(googlesheets4)

# Read google sheets data into R
gs4_deauth()
x <- read_sheet('https://docs.google.com/spreadsheets/d/1pMQ1PUSKw4Fd7f21yGokdLx1EuQtn2KAGvaGyrjNU7Q')
