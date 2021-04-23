setwd("~/Documents/R")
source("api_postgres.R")
start <- Sys.time()

####ARCHBOLD####
outpath <- "~/Documents/data/archbold" #change this to wherever your files live
my_token <- "c614f19f1a6c51eb6dca2324d79b1802968cec4724f671a62dfcd3ec5404031b"
db_name = "archbold"
#conn <- dbConnect(RPostgres::Postgres(), dbname=db_name)
################

get_my_data(my_token, outpath) #conn

#update_db(conn, outpath)
#dbDisconnect(conn)

time_elapse <- Sys.time() - start
print(time_elapse)