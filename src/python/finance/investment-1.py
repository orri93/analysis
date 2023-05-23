import pandas as pd

sheet_id = "1XqOtPkiE_Q0dfGSoyxrH730RkwrTczcRbDeJJpqRByQ"
# sheet_id = "1pMQ1PUSKw4Fd7f21yGokdLx1EuQtn2KAGvaGyrjNU7Q"
sheet_name = "sample_1"
# sheet_name = "Buy"
url = f"https://docs.google.com/spreadsheets/d/{sheet_id}/gviz/tq?tqx=out:csv&sheet={sheet_name}"

data = pd.read_csv(url)
data
