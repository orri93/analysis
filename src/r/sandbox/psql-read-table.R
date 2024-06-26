# PostgreSQL Read Table example
#
# See also https://www.datacareer.de/blog/connect-to-postgresql-with-r-a-step-by-step-example/

# Uses the RPostgreSQL package
# Install the RPostgreSQL package with
# install.packages('RPostgreSQL')

library(RPostgreSQL)

# Connect to the DB
driver = dbDriver("PostgreSQL")
connection = dbConnect(driver, host = "172.17.114.129", port = 5432, user = "orri", password = "Bios93", dbname = "sandbox")

# To check if the connection is established
dbListTables(connection)

sandbox <- dbReadTable(connection, "sandbox")

dbmtcars <- dbReadTable(connection, "mtcars")

# Clean up DB connection
dbDisconnect(connection)
