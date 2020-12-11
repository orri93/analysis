# PostgreSQL insert example
#
# See also https://jarrettmeyer.com/2018/11/08/r-postgresql-insert

# SQL for the Sandbox table used in the example
#
# CREATE TABLE public.sandbox (
#   id integer NOT NULL DEFAULT nextval('sandbox_id_seq'::regclass),
#   t timestamp without time zone NOT NULL,
#   r double precision,
#   s character varying(32) COLLATE pg_catalog."default",
#   i integer,
#   b boolean,
#   CONSTRAINT sandbox_pkey PRIMARY KEY (id)
# )

# Uses the RPostgreSQL package
# Install the RPostgreSQL package with
# install.packages('RPostgreSQL')

library(RPostgreSQL)

# creating a data set
t <- c('2020-12-11 14:44:00', '2020-12-11 14:45:00', '2020-12-11 14:46:00')
r <- c(11.23, 34.56, 85.34)
s <- c('abc', "def", "ghi")
i <- c(2, 3, 5)
b <- c(TRUE, FALSE, TRUE)
d <- data.frame(t, r, s, i, b)

# The SQL
sqlstm <- paste("INSERT INTO sandbox (t, r, s, i, b) VALUES ($1, $2, $3, $4, $5)")
print(paste("SQL Statement: ", sqlstm))

# Connect to the DB
driver = dbDriver("PostgreSQL")
connection = dbConnect(driver, host = "172.17.114.129", port = 5432, user = "orri", password = "Bios93", dbname = "sandbox")

# Insert
reccount <- nrow(d)
for (i in seq_len(reccount)) {
  row = d[i,]
  dbExecute(connection, sqlstm, row)
}
print(paste("Inserted", reccount, "rows."))

# Clean up DB connection
dbDisconnect(connection)
