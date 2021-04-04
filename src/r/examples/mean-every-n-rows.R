# Calculate the mean of every 13 rows in data frame
# https://stackoverflow.com/questions/30359427/calculate-the-mean-of-every-13-rows-in-data-frame
#

# Example calculates mean for every 5 rows

#  a	 b		
#  1	13		
#  2	14		
#  3	15		
#  4	16		
#  5	17	3	15
#  6	18		
#  7	19		
#  8	20		
#  9	21		
# 10	22	8	20
# 11	23		
# 12	24	11.5	23.5

n <- 5;
df <- data.frame(a = 1:12, b = 13:24);
mycars <- copy(cars)


# Using aggregate() and rep().
# Verified to work by calculating again in Excel
#
aggregate(df, list(rep(1:(nrow(df) %/% n + 1), each = n, len = nrow(df))), mean)[-1];
aggregate(mycars, list(rep(1:(nrow(mycars) %/% n + 1), each = n, len = nrow(mycars))), mean)[-1];


# As function
#
n.colmeans = function(df, n = 5) {
  aggregate(x = df,
            by = list(gl(ceiling(nrow(df)/n), n)[1:nrow(df)]),
            FUN = mean)
}
n.colmeans(df, 5)


# dplyr way
#
df %>% group_by(mean = (row_number() - 1) %/% n) %>% mutate(mean = mean(a))


# If df is a data.table, you can use %/% to group as in
#
library(data.table)
setDT(df)
setDT(mycars)

df[, mean(a), by = (seq(nrow(df)) - 1) %/% n]
mycars[, mean(speed), by = (seq(nrow(mycars)) - 1) %/% n]

# for every nTH row, use %% instead of %/%
df[, mean(a), by = (seq(nrow(df)) - 1) %% n]
