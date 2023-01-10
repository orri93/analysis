# Processing data from Baker Huges Rig Count
# See https://bakerhughesrigcount.gcs-web.com/na-rig-count

library(readxlsb)
library(openxlsx)
library(httr)

burl <- 'https://bakerhughesrigcount.gcs-web.com/static-files'
bpa  <- 'tmp/oilandgas/bakerhughes'

wgbhrc <- function(id, file) {
  fpath <- paste(bpa, file, sep='/')
  GET(paste(burl, id, sep='/'), write_disk(fpath, overwrite=TRUE))
  fpath
}

curfpath <- wgbhrc('41eaa364-4a9b-409d-8ed8-9aa225c1c10a', 'north_america_rotary_rig_count_jan_2000_-_current.xlsb')
curpivotfpath <- wgbhrc('2192f290-abb8-4e25-9e1a-e0c8474f3069', 'north_american_rotary_rig_count_pivot_table_feb_2011_-_current.xlsb')

usbytraj <- read_xlsb(curfpath, sheet=5, skip=5)
curpivot <- read_xlsb(curpivotfpath, sheet=2)

rawwwrc <- read.xlsx(paste(bpa, 'Worldwide Rig Count Sep 2022.xlsx', sep='/'))

wwrc <- data.frame()
for (row in 1:nrow(rawwwrc)) {
  x2 <- rawwwrc[row, "X2"]
  rawyear <- suppressWarnings(as.numeric(x2))
  if (is.na(rawyear)) {
    month <- match(x2, month.abb)
    if (!is.na(month)) {
      nextrow <- nrow(wwrc)+1
      wwrc[nextrow, 'year'] = year
      wwrc[nextrow, 'month'] = month
      wwrc[nextrow, 'Latin America'] = rawwwrc[row, "X3"]
      wwrc[nextrow, 'Europe'] = rawwwrc[row, "X4"]
      wwrc[nextrow, 'Africa'] = rawwwrc[row, "X5"]
      wwrc[nextrow, 'Middle East'] = rawwwrc[row, "X6"]
    }
  } else {
    year = rawyear
  }
}
