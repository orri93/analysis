# PostgreSQL Query example
#
# See also https://www.datacareer.de/blog/connect-to-postgresql-with-r-a-step-by-step-example/

# Uses the RPostgreSQL package
# Install the RPostgreSQL package with
# install.packages('RPostgreSQL')

library(RPostgreSQL)

# Connect to the DB
driver = dbDriver("PostgreSQL")
connection = dbConnect(driver, host = "172.17.114.129", port = 5432, user = "orri", password = "Bios93", dbname = "sandbox")

# method returns an overview of the data stored in the database and basically
# does the same function as
dbGetQuery(connection, 'SELECT * FROM mtcars') 

# Creating basic queries

# The way of creating queries for a customized data table is basically the same
# as in SQL. The only difference is that the results of queries in R are stored
# as a variable.
carsquery <- dbSendQuery(connection, 'SELECT "row.names", cyl, gear FROM mtcars WHERE cyl >= 5 AND gear >= 4')
result <- dbFetch(carsquery)
dbClearResult(carsquery)

# Clean up DB connection
dbDisconnect(connection)
