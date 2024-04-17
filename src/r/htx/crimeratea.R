# Investigate Houston Texas Police Department monthly crime data by stret and police beat
#

library(plyr)
library(tidyverse)
library(lubridate)
library(RODBC)

# Import data from files
con2019 <- odbcConnectExcel2007('tmp/htxpolice/NIBRSPublicView2019.xlsb')
raw2019 <- sqlFetch(con2019, "CrimeData2019")
con2020 <- odbcConnectExcel2007('tmp/htxpolice/NIBRSPublicView2020.xlsb')
raw2020 <- sqlFetch(con2020, "CrimeData2020")
con2021 <- odbcConnectExcel2007('tmp/htxpolice/NIBRSPublicView2021.xlsb')
raw2021 <- sqlFetch(con2021, "CrimeData2021")
con2022 <- odbcConnectExcel2007('tmp/htxpolice/NIBRSPublicView2022.xlsb')
raw2022 <- sqlFetch(con2022, "CrimeData2022")
con2023 <- odbcConnectExcel2007('tmp/htxpolice/NIBRSPublicView2023.xlsx')
raw2023 <- sqlFetch(con2023, "CrimeData2023")
con2024 <- odbcConnectExcel2007('tmp/htxpolice/NIBRSPublicView2024.xlsx')
raw2024 <- sqlFetch(con2024, "CrimeData2024")
odbcCloseAll()
rm(con2019, con2020, con2021, con2022, con2023, con2024)

# Wrangling
rawcd <- rbind(raw2019, raw2020, raw2021, raw2022, raw2023, raw2024)
crimedata <- rawcd %>% mutate(OccurrenceDate = as.Date(RMSOccurrenceDate))
crimedata <- crimedata %>% mutate(Year = year(OccurrenceDate))
crimedata77079 <- crimedata %>% filter(ZIPCode == 77079)
crimedatadairyashfordrd <- crimedata77079 %>% filter(StreetName == "DAIRY ASHFORD")
crimedatadairyashfordrd1200 <- crimedatadairyashfordrd %>% filter(StreetNo == 1200)
crimedatadairyashfordrd2352 <- crimedatadairyashfordrd %>% filter(StreetNo == 2352)
crimedata77077 <- crimedata %>% filter(ZIPCode == 77077)
crimedataeldridge <- crimedata77077 %>% filter(StreetName == "ELDRIDGE")
crimedataeldridge1420 <- crimedataeldridge %>% filter(StreetNo == 1420)

byzipcode <- plyr::count(crimedata, "ZIPCode")
bystreetname <- plyr::count(crimedata, "StreetName")

byyearzip <- plyr::count(crimedata, c("Year", "ZIPCode"))
