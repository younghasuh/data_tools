library(httr)
library(DBI)
library(RPostgres)
library(data.table)
library(tidyverse)

Correct_Colnames <- function(df) {
  rowval <- gsub("^X\\.", "-",  colnames(df))
  rowval <- gsub("^X", "",  rowval)
  DatePattern = '^[[:digit:]]{4}\\.[[:digit:]]{2}\\.[[:digit:]]{2}[T,\\.][[:digit:]]{2}\\.[[:digit:]]{2}\\.[[:digit:]]{2}(.[[:digit:]]{3})?[Z]?'
  rowval[which(grepl(DatePattern,rowval))] <- as.character(as.POSIXct(rowval[grepl(DatePattern,rowval)], format="%Y.%m.%d.%H.%M.%S", tz="UTC"))
  #colnames(df) <- c("Time", "TagId", "BitErr", "TagRSSI", "NodeId", "NodeFreq", "RadioId")
  #names(rowval) <- colnames(df)
  #df <- rbind(df, rowval)
  #X might be replaced by different characters, instead of being deleted
  return(rowval)}

is.POSIXct <- function(x) inherits(x, "POSIXct")  
#github_pat <- function() {
#  pat <- Sys.getenv('GITHUB_PAT')
#  if (identical(pat, "")) {
#    stop("Please set env var GITHUB_PAT to your github personal access token",
#         call. = FALSE)
#  }
  
#  pat
#}

host <- 'https://account.celltracktech.com'
project <- '/station/api/projects/'
stations <- '/station/api/stations/'
files <- '/station/api/file-list/'
file_types <- c("data", "node-data", "gps", "log", "telemetry", "sensorgnome")

post <- function(endpoint, payload=NULL) {
  payload_to_send <- list(token=my_token)
  if (!is.null(payload)) {
    payload_to_send <- c(payload_to_send, payload)
  }
  response <- POST(host, path = endpoint, body=payload_to_send,encode="json", timeout(60)) 
  stop_for_status(response)
  return(content(response))
}

#22 CTT Meadows
#73 Meadows V2
#projects <- list(projects[[41]])

getStations <- function(project_id) {
  out <- post(endpoint=stations, payload=list("project-id"=project_id))
  return(out)
}
  
 # dbExecute(conn, "CREATE TABLE tag
#  (
#    id	TEXT PRIMARY KEY
#  )")

getStationFileList <- function(station_id, begin, filetypes=NULL, end=NULL) {
  endpoint <- files
  payload <- list("station-id" = station_id, begin = as.Date(begin))
  if (!is.null(filetypes)) {
    add_types <- filetypes[filetypes %in% file_types]
    if(length(which(!filetypes %in% file_types)) > 0) {print(paste("WARNING: invalid file type specified - ignoring:",filetypes[!filetypes %in% file_types]))}
    payload[['file-types']] = add_types
  } 
  if (!is.null(end)) {payload[['end']] = as.Date(end)}
return(post(endpoint=endpoint, payload=payload))}

downloadFiles <- function(file_id) {
  endpoint <- "/station/api/download-file/"
  payload <- list("file-id"=file_id)
  #print(paste("payload:",payload))
  return(post(endpoint=endpoint, payload=payload))
}

create_db <- function(conn, projects) {
dbExecute(conn, "CREATE TABLE IF NOT EXISTS ctt_project
  (
    id	INTEGER PRIMARY KEY,
    name	TEXT NOT NULL UNIQUE
  )")
#
dbExecute(conn, "CREATE TABLE IF NOT EXISTS station
  (
    station_id	TEXT PRIMARY KEY
  )")

dbExecute(conn, "CREATE TABLE IF NOT EXISTS nodes
  (
    node_id TEXT NOT NULL PRIMARY KEY
  )")

dbExecute(conn, "CREATE TABLE IF NOT EXISTS data_file
  (
    path TEXT PRIMARY KEY
  )")

dbExecute(conn, "CREATE TABLE IF NOT EXISTS ctt_project_station 
  (
    db_id	INTEGER PRIMARY KEY,
    project_id	INTEGER NOT NULL,
    station_id	TEXT NOT NULL,
    deploy_at	TIMESTAMP with time zone,
    end_at	TIMESTAMP with time zone,
    FOREIGN KEY (project_id) 
      REFERENCES ctt_project (id) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (station_id) 
      REFERENCES station (station_id) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
  )")

#    id	INTEGER PRIMARY KEY, --Autoincrement
dbExecute(conn, "CREATE TABLE IF NOT EXISTS raw 
  (
    path  TEXT,
    radio_id INTEGER,
    tag_id TEXT,
    node_id TEXT,
    tag_rssi INTEGER,
    validated INTEGER,
    time TIMESTAMP with time zone,
    station_id TEXT,
    FOREIGN KEY (station_id) 
      REFERENCES station (station_id) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (node_id) 
      REFERENCES nodes (node_id) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
  )")

#        id	SERIAL PRIMARY KEY,
# id	INTEGER PRIMARY KEY, --Autoincrement
#    FOREIGN KEY (path) 
#REFERENCES data_file (path) 
#ON DELETE NO ACTION
#ON UPDATE NO ACTION
dbExecute(conn, "CREATE TABLE IF NOT EXISTS node_health
  (
    time TIMESTAMP with time zone,
    radio_id INTEGER,
    node_id TEXT,
    node_rssi INTEGER,
    battery NUMERIC,
    celsius NUMERIC,
    recorded_at TIMESTAMP with time zone,
    firmware TEXT,
    solar_volts NUMERIC,
    solar_current NUMERIC,
    cumulative_solar_current NUMERIC,
    latitude NUMERIC,
    longitude NUMERIC,
    station_id TEXT,
    path  TEXT,
    FOREIGN KEY (node_id) 
      REFERENCES nodes (node_id) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
  )")
#    id	SERIAL PRIMARY KEY,    
#PRIMARY KEY (radio_id, node_id, time, station_id),
#    id	INTEGER PRIMARY KEY, --Autoincrement
#    FOREIGN KEY (path) 
#REFERENCES data_file (path) 
#ON DELETE NO ACTION
#ON UPDATE NO ACTION
dbExecute(conn, "CREATE TABLE IF NOT EXISTS gps
  (
    path  TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    altitude NUMERIC,
    quality INTEGER,
    gps_at TIMESTAMP with time zone,
    recorded_at TIMESTAMP with time zone,
    station_id TEXT,
    mean_lat NUMERIC,
    mean_lng NUMERIC,
    n_fixes INTEGER,
    PRIMARY KEY (gps_at, station_id)
  )")
#    FOREIGN KEY (path) 
#REFERENCES data_file (path) 
#ON DELETE NO ACTION
#ON UPDATE NO ACTION
sapply(projects, function(a) {
  b <- unname(as.data.frame(a))
  vars <- paste(dbListFields(conn, "ctt_project"), sep="", collapse=",")
  insertnew <- dbSendQuery(conn, paste("INSERT INTO ","ctt_project"," (",vars,") VALUES ($2, $1) ON CONFLICT DO NOTHING",sep="")) 
  #it is possible you should be using dbSendStatement for all of these
  dbBind(insertnew, params=b)
  dbClearResult(insertnew)
  
  basename <- a$name
  id <- a[['id']]
  my_stations <- getStations(project_id=id)
  
  mystations <- lapply(my_stations$stations, function(c) {
    c <- as.data.frame(t(unlist(c)), stringsAsFactors=FALSE)
    
    c$project_id <- id
    colnames(c)[colnames(c)=="station.db-id"] <- "db_id"
    colnames(c)[colnames(c)=="station.id"] <- "station_id"
    colnames(c)[colnames(c)=="deploy-at"] <- "deploy_at"
    if (is.null(c$`end-at`)) {
      c$end_at <- NA} else {colnames(c)[colnames(c)=="end-at"] <- "end_at"}
    return(c)})
  mystations <- as.data.frame(rbindlist(mystations, fill=TRUE))
  MYSTATIONS <- list(unique(mystations$station_id))
  mystations <- unname(mystations)
  print(mystations)
  
  insertnew <- dbSendQuery(conn, paste("INSERT INTO ","station (station_id)"," VALUES ($1)
                                       ON CONFLICT DO NOTHING",sep=""))
  dbBind(insertnew, params=MYSTATIONS)
  dbClearResult(insertnew)
  
  vars <- paste(dbListFields(conn, "ctt_project_station"), sep="", collapse=",")
  print(vars)
  insertnew <- dbSendQuery(conn, paste("INSERT INTO ","ctt_project_station"," (",vars,") VALUES ($1, $4, $2, $3, $5)
                                       ON CONFLICT DO NOTHING",sep=""))
  dbBind(insertnew, params=mystations) #where end-at error happens
  dbClearResult(insertnew)
})
}

db_insert <- function(contents, filetype, conn, sensor, y) {
  print(filetype)
  contents[,unname(which(sapply(contents, is.POSIXct)))] <- ifelse(nrow(contents[,unname(which(sapply(contents, is.POSIXct)))]) > 1,
                                                                   as_tibble(apply(contents[,unname(which(sapply(contents, is.POSIXct)))], 2, function(g) paste(as.character(g), "UTC"))),
    bind_rows(apply(contents[,unname(which(sapply(contents, is.POSIXct)))], 2, function(g) paste(as.character(g), "UTC"))))
  contents <- data.frame(contents)
  delete.columns <- grep("(^X)", colnames(contents), perl=T)
  if (length(delete.columns) > 0) {
    contents <- rbind(contents,Correct_Colnames(contents))
  }
  contents$station_id <- sensor
  contents$path <- y

  if(!is.null(contents)) {
    if (filetype == "gps") {
      if (length(delete.columns) > 0) {
        if(ncol(contents) > 9) {
          names(contents) <- c("recorded.at","gps.at","latitude","longitude","altitude","quality","mean.lat","mean.lng","n.fixes","station_id",
                               "path")
        }}
      colnames(contents)[colnames(contents)=="recorded.at"] <- "recorded_at"
      contents$recorded_at <- as.character(contents$recorded_at)
      colnames(contents)[colnames(contents)=="gps.at"] <- "gps_at"
      contents$gps_at <- as.character(contents$gps_at)
      if ("mean lat" %in% colnames(contents)) {
        colnames(contents)[colnames(contents)=="mean.lat"] <- "mean_lat"
        colnames(contents)[colnames(contents)=="mean.lng"] <- "mean_lng"
        colnames(contents)[colnames(contents)=="n.fixes"] <- "n_fixes"
      } else {
        contents$mean_lat <- NA
        contents$mean_lng <- NA
        contents$n_fixes <- NA
      }
    names(contents) <- sapply(names(contents), function(x) gsub('([[:lower:]])([[:upper:]])', '\\1_\\2', x))
    } else if (filetype == "raw") {
      if (length(delete.columns) > 0) {
        if(ncol(contents) > 7) {
          names(contents) <- c("time","RadioId","TagId","TagRSSI","NodeId","validated","station_id", "path")
        }
      }
      print(names(contents))
      if (!(any(tolower(names(contents))=="validated"))) {contents$validated <- NA}
      contents$RadioId <- as.integer(contents$RadioId)
      contents$TagRSSI <- as.integer(contents$TagRSSI)
      if (length(which(!is.na(contents$NodeId))) > 0) {
        nodeids <- contents$NodeId[which(!is.na(contents$NodeId))]
        insertnew <- dbSendQuery(conn, paste("INSERT INTO ","nodes (node_id)"," VALUES ($1)
                                           ON CONFLICT DO NOTHING",sep=""))
        dbBind(insertnew, params=list(unique(nodeids)))
        dbClearResult(insertnew)
      }
      names(contents) <- sapply(names(contents), function(x) gsub('([[:lower:]])([[:upper:]])', '\\1_\\2', x))
    } else if (filetype == "node_health") {
      if (length(delete.columns) > 0) {
        if(ncol(contents) > 9) {
          names(contents) <- c("time","RadioId","NodeId","NodeRssi","battery","celsius","RecordedAt","firmware","SolarVolts","SolarCurrent","CumulativeSolarCurrent","latitude","longitude","station_id",
                               "path")
        }
      }
      if(ncol(contents) < 9) {
        contents$RecordedAt <- NA
        contents$Firmware <- NA
        contents$SolarVolts <- NA
        contents$SolarCurrent <- NA
        contents$CumulativeSolarCurrent <- NA
        contents$Latitude <- NA
        contents$Longitude <- NA
      }
      nodeids <- unique(contents$NodeId)
      insertnew <- dbSendQuery(conn, paste("INSERT INTO ","nodes (node_id)"," VALUES ($1)
                                           ON CONFLICT DO NOTHING",sep=""))
      dbBind(insertnew, params=list(unique(nodeids)))
      dbClearResult(insertnew)
      names(contents) <- sapply(names(contents), function(x) gsub('([[:lower:]])([[:upper:]])', '\\1_\\2', x))
    } else {nodeids <- c()}
    if (filetype %in% c("raw", "node_health", "gps")) {
      print(str(contents))
      print(dbListFields(conn, filetype))
      #if (filetype == "raw" | filetype == "node_health")
      #{
      #  vars <- paste(dbListFields(conn, filetype)[2:length(dbListFields(conn, filetype))], sep="", collapse=",") 
      #  vals <- paste(seq_along(1:(length(dbListFields(conn, filetype))-1)), sep="", collapse = ", $")
      #  names(contents) <- tolower(names(contents))
      #  contents <- contents[,dbListFields(conn, filetype)[2:length(dbListFields(conn, filetype))]]
      #} else {
      vars <- paste(dbListFields(conn, filetype), sep="", collapse=",") 
      vals <- paste(seq_along(1:length(dbListFields(conn, filetype))), sep="", collapse = ", $")
      names(contents) <- tolower(names(contents))
      contents <- contents[,dbListFields(conn, filetype)]
      #}
      contents <- unname(contents)
      insertnew <- dbSendQuery(conn, paste("INSERT INTO ",filetype," (", vars, ") VALUES ($", vals ,")",sep="")) #PICK UP RIGHT HERE!!! EXEC SQL WHENEVER SQLERROR CONTINUE;
      #ON CONFLICT (time) DO NOTHING
      dbBind(insertnew, params=contents)
      dbClearResult(insertnew)
      
      insertnew <- dbSendQuery(conn, paste("INSERT INTO ","data_file (path)"," VALUES ($1)
                                         ON CONFLICT DO NOTHING",sep=""))
      dbBind(insertnew, params=list(y))
      dbClearResult(insertnew)
    }
  }
  if(!exists("h")) {h <- NULL}
return(h)}

get_data <- function(project, outpath, f=NULL) {
  myfiles <- list.files(outpath, recursive = TRUE)
  files_loc <- sapply(strsplit(myfiles, "/"), tail, n=1)
  basename <- project$name
  id <- project[['id']]
  dir.create(file.path(outpath, basename), showWarnings = FALSE)
  my_stations <- getStations(project_id=id)

#station <- my_stations[['stations']][[35]]
#kwargs <- list(
#  station_id = station[["station"]][["id"]],
#  begin = as.POSIXct(station[['deploy-at']],format="%Y-%m-%dT%H:%M:%OS",tz = "UTC", optional=TRUE)
#)
#if(!is.null(station[['end-at']])) {
#  kwargs[['end']] = as.POSIXct(station[['end-at']],format="%Y-%m-%dT%H:%M:%OS",tz = "UTC", optional=TRUE)
#}
#file_info <- do.call(getStationFileList, kwargs)
#files = file_info[['files']]

  files_avail <- lapply(my_stations[["stations"]], function(station) {
    print(station)
    kwargs <- list(
      station_id = station[["station"]][["id"]],
      begin = as.POSIXct(station[['deploy-at']],format="%Y-%m-%dT%H:%M:%OS",tz = "UTC", optional=TRUE)
    )
  
    if(!is.null(station[['end-at']])) {
      kwargs[['end']] = as.POSIXct(station[['end-at']],format="%Y-%m-%dT%H:%M:%OS",tz = "UTC", optional=TRUE)
    }
    file_info <- do.call(getStationFileList, kwargs)
    outfiles <- file_info[['files']]
  return(outfiles)})
  
  filenames <- unname(rapply(files_avail, grep, pattern = "CTT", value=TRUE))
  files_to <- filenames[!filenames %in% files_loc]

  allfiles <- rapply(files_avail, function(z) z %in% files_to, how = "unlist")
  ids <- unlist(files_avail)[which(allfiles) - 1]
  file_names <- unlist(files_avail)[which(allfiles)]

  get_files <- function(x, y) {
    
    print(x)
    print(y)

    splitfile <- unlist(strsplit(y, "CTT-"))
    fileinfo <- splitfile[2]
    sensorid <- unlist(strsplit(fileinfo,"-"))
    sensor <- sensorid[1]
    filenameinfo <- sensorid[2]
    file_info <- unlist(strsplit(filenameinfo, "\\."))[1]
    filetype <- ifelse(is.na(as.integer(file_info)),file_info,"sensorgnome")
    print(filetype)
    if (is.na(filetype)) {
      filetype <- "none"
    } else if (filetype == "node") {
      filetype <- "node_health"
    } else if (filetype == "data") {
      filetype <- "raw"
    }
    
    if (filetype != "log" & filetype != "telemetry" & filetype != "sensorgnome") {
      contents = downloadFiles(file_id = x)
      if (!is.null(contents)) {
      dir.create(file.path(outpath, basename, sensor), showWarnings = FALSE)
      dir.create(file.path(outpath, basename, sensor, filetype), showWarnings = FALSE)
      print(paste("downloading",y,"to",file.path(outpath, basename, sensor, filetype)))
      print(x)
      write.csv(contents, file=gzfile(file.path(outpath, basename, sensor, filetype, y)), row.names=FALSE)
      if(!is.null(f)) {
        z <- db_insert(contents, filetype, f, sensor, y)
      }
      }
    }
    if(!exists("z")) {z <- NULL}
  return(z)}

failed <- Map(get_files, ids, file_names)
failed <- failed[unname(which(!is.null(failed)))]
return(failed)}

get_my_data <- function(my_token, outpath, db_name=NULL) {
  projects <- content(POST(host, path = project, body = list(token=my_token), encode="json", verbose()), "parsed")
  projects <- projects[['projects']]
  if(!is.null(db_name)) {
    create_db(db_name, projects)
    failed <- lapply(projects, get_data, f=db_name, outpath=outpath)
  } else {
      failed <- lapply(projects, get_data, outpath=outpath)
    }
  save(failed,file="caught.RData")
}

#insertnew <- dbSendQuery(conn, paste("INSERT OR IGNORE INTO ","nodes (NodeId)"," VALUES ($)",sep=""))
#dbBind(insertnew, params=list(unique(allnodes)))
#dbClearResult(insertnew)

pop <- function(x) { #this was a function written before the data file table was added, no one should need this
  allnode <- dbReadTable(x, "node_health")
  allgps <- dbReadTable(x, "gps")
  allbeep <- dbReadTable(x, "raw")
  insertnew <- dbSendQuery(conn, paste("INSERT OR IGNORE INTO ","data_file (path)"," VALUES ($)",sep=""))
  dbBind(insertnew, params=list(unique(c(allnode$path, allgps$path, allbeep$path))))
  dbClearResult(insertnew)
  
  insertnew <- dbSendQuery(conn, paste("INSERT OR IGNORE INTO ","nodes (node_id)"," VALUES ($)",sep=""))
  dbBind(insertnew, params=list(unique(allnode$node_id)))
  dbClearResult(insertnew)
}

update_db <- function(d, outpath) {
  myfiles <- list.files(outpath, recursive = TRUE)
  files_loc <- sapply(strsplit(myfiles, "/"), tail, n=1)
  allnode <- dbReadTable(d, "data_file")
  files_import <- myfiles[which(!files_loc %in% allnode$path)]
  write.csv(files_import, "files.csv")
  lapply(files_import, get_files_import, conn=d, outpath=outpath)
}

get_files_import <- function(e, conn, outpath) {
  e <- file.path(outpath, e)
  print(e)
  y <- tail(unlist(strsplit(e, "/")), n=1)

  splitfile <- unlist(strsplit(y, "CTT-"))
  fileinfo <- splitfile[2]
  sensorid <- unlist(strsplit(fileinfo,"-"))
  sensor <- sensorid[1]
  filenameinfo <- sensorid[2]
  file_info <- unlist(strsplit(filenameinfo, "\\."))[1]
  filetype <- ifelse(is.na(as.integer(file_info)),file_info,"sensorgnome")
  #print(filetype)
  if (is.na(filetype)) {
    filetype <- "none"
  } else if (filetype == "node" & !is.na(filetype)) {
    filetype <- "node_health"
  } else if (filetype == "data") {
      filetype <- "raw"
    }
  if (filetype %in% c("raw", "node_health", "gps")) {
  contents <- tryCatch({
    if (file.size(e) > 0) {
      read_csv(e) # as.is=TRUE, na.strings=c("NA", ""), header=TRUE, skipNul = TRUE, colClasses=c("NodeId"="character","TagId"="character")
    }}, error = function(err) {
      # error handler picks up where error was generated, in Bob's script it breaks if header is missing
      #print(paste("error reading", e))
      return(NULL)
    })
    if(!is.null(contents)) {
      z <- db_insert(contents, filetype, conn, sensor, y)
      #insertnew <- dbSendQuery(conn, paste("INSERT INTO ","data_file (path)"," VALUES ($1)ON CONFLICT DO NOTHING",sep=""))
      #dbBind(insertnew, params=list(y))
      #dbClearResult(insertnew)
      }
  }
  if(!exists("z")) {z <- NULL}
}

#basename <- Archbold
#y <- "CTT-CC3AD37CA9D6-raw-data.2021-04-21_143937.csv.gz"
#f <- conn
#x <- 3477970

inserttest_prepdownload <- function(x, basename, y, outpath) { #f
  print(x)
  print(y)
  
  splitfile <- unlist(strsplit(y, "CTT-"))
  fileinfo <- splitfile[2]
  sensorid <- unlist(strsplit(fileinfo,"-"))
  sensor <- sensorid[1]
  print(sensor)
  filenameinfo <- sensorid[2]
  file_info <- unlist(strsplit(filenameinfo, "\\."))[1]
  filetype <- ifelse(is.na(as.integer(file_info)),file_info,"sensorgnome")
 
  if (is.na(filetype)) {
    filetype <- "none"
  } else if (filetype == "node") {
    filetype <- "node_health"
  } else if (filetype == "data") {
    filetype <- "raw"
  }
  print(filetype)
  contents = downloadFiles(file_id = x)
  if (!is.null(contents)) {
    dir.create(file.path(outpath, basename, sensor), showWarnings = FALSE)
    dir.create(file.path(outpath, basename, sensor, filetype), showWarnings = FALSE)
    print(paste("downloading",y,"to",file.path(outpath, basename, sensor, filetype)))
    print(x)
    write.csv(contents, file=gzfile(file.path(outpath, basename, sensor, filetype, y)), row.names=FALSE)
    #if(!is.null(f)) {
    #  z <- db_insert(contents, filetype, f, sensor, y)
    #}
  }
return(contents)}

#e <- "Archbold/867762040727353/data/CTT-867762040727353-data.2019-12-11_230224.csv.gz"
inserttest_prepread <- function(e, outpath) {
  e <- file.path(outpath, e)
  print(e)
  y <- tail(unlist(strsplit(e, "/")), n=1)
  
  splitfile <- unlist(strsplit(y, "CTT-"))
  fileinfo <- splitfile[2]
  sensorid <- unlist(strsplit(fileinfo,"-"))
  sensor <- sensorid[1]
  filenameinfo <- sensorid[2]
  file_info <- unlist(strsplit(filenameinfo, "\\."))[1]
  filetype <- ifelse(is.na(as.integer(file_info)),file_info,"sensorgnome")
  #print(filetype)
  if (is.na(filetype)) {
    filetype <- "none"
  } else if (filetype == "node" & !is.na(filetype)) {
    filetype <- "node_health"
  } else if (filetype == "data") {
    filetype <- "raw"
  }
  if (filetype %in% c("raw", "node_health", "gps")) {
    contents <- tryCatch({
      if (file.size(e) > 0) {
        read_csv(e) # as.is=TRUE, na.strings=c("NA", ""), header=TRUE, skipNul = TRUE, colClasses=c("NodeId"="character","TagId"="character")
      }}, error = function(err) {
        # error handler picks up where error was generated, in Bob's script it breaks if header is missing
        #print(paste("error reading", e))
        return(NULL)
      })}
return(contents)}

#start <- Sys.time()
#db_insert(downloaded, "raw", conn, "CC3AD37CA9D6", "CTT-CC3AD37CA9D6-raw-data.2021-04-21_143937.csv.gz")
#time_elapse <- Sys.time() - start
