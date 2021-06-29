source("functions/api_postgres.R")
start <- Sys.time()

####SETTINGS####
outpath <- "/download" 
my_token <- "ae45d3ab909039f9c7f48d51c1888a9864d77388ba40b28a3bf2db5c9fa18597"
db_name <- "Archbold"
conn <- dbConnect(RPostgres::Postgres(), 
                  user = "postgres", 
                  password = "younghasuh", 
                  dbname = db_name)
################

get_my_data(my_token, outpath, conn)

update_db(conn, outpath)
dbDisconnect(conn)

time_elapse <- Sys.time() - start
print(time_elapse)

