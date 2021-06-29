Calibration test with new localization
================
Young
11/23/2020

Adopted script from Jessica Gorzo

Load libraries

``` r
library(sf)
library(ggrepel)
source("functions/localization.R")
source("functions/data_manager.R")
```

Set working directory and load data; edit accordingly

``` r
# Get beep data
#setwd("C:/Users/young/Desktop/CTTdata/CTT_data_tools/calibrationtest") # edit according to your device
beep_data <- read.csv("archbold-calibration-data.csv", as.is=TRUE, na.strings=c("NA", ""))

# Set up tag data
tags <- read.csv("Archbold_Expt_Data.csv", as.is=TRUE, na.strings=c("NA", "")) #uppercase node letters
tags$Comments <- NULL
tags$NodeID <- toupper(tags$NodeID)
tags$End.Time[31:33] <- "9:14"
tags$date <- as.Date(paste(2019, tags$Date), format="%Y %d %b")
tags$session_id <- rownames(tags)
tags$start <- as.POSIXct(paste(tags$date, tags$Start.Time), tz="America/New_York")
tags$end <- as.POSIXct(paste(tags$date, tags$End.Time), tz="America/New_York")
tags$PlatformID <- as.character(tags$PlatformID)
tags[tags$Rotation=="still",]$PlatformID <- "still"

# Set up platform information
plat1 <- c("61335578", "6134074B", "61664C61", "61611E2D")
plat2 <- c("6133331E", "61336634", "61526633", "6166194C")
still <- c("61664B1E", "6166194B")
mytags <- c(plat1, plat2, still)

# Set up beep data
beep_data <- beep_data[beep_data$TagId %in% mytags,] # limit beep data to tags of interest

beep_data$PlatformID <- NA
beep_data$PlatformID[beep_data$TagId %in% still] <- "still"
beep_data$PlatformID[beep_data$TagId %in% plat1] <- "1"
beep_data$PlatformID[beep_data$TagId %in% plat2] <- "2"
beep_data$Time <- as.POSIXct(beep_data$Time, tz = "GMT")
beep_data$time_est <- beep_data$Time
attributes(beep_data$time_est)$tzone <- "America/New_York" #convert time zones GMT -> EST

# filter out NA 
beep_data <- beep_data[!is.na(beep_data$PlatformID),]

#
dt1 <- data.table(beep_data, start=beep_data$time_est, end=beep_data$time_est)
dt2 <- data.table(tags)
setkey(dt2, PlatformID, start, end) # create key on data.table by columns PlatformID, start, and end

indx <- foverlaps(dt1, dt2, type='within') #fast overlap joins
indx <- indx[!is.na(indx$Date),]
indx$Date <- NULL
indx$start <- NULL
indx$end <- NULL
indx$i.start <- NULL
indx$i.end <- NULL

indx$NodeId <- toupper(indx$NodeId)


# Import node list
nodes <- read.csv("archbold-nodes.csv", as.is=TRUE, na.strings=c("NA", ""), strip.white=TRUE) #uppercase node letters
nodes <- nodes[,c("NodeId", "lat", "lng")]
nodes$NodeId <- toupper(nodes$NodeId)
beep_data <- indx[indx$NodeId %in% nodes$NodeId,] 
# beep_data$id <- paste(beep_data$TagId, beep_data$session_id) # I don't understand why this is a combo of tagID and sessionID
beep_data <- as.data.frame(beep_data)
pts <- beep_data[!duplicated(beep_data$NodeID),] # remove duplicates
beep_data <- merge(beep_data, nodes, by.x="NodeID", by.y="NodeId", all.x = TRUE)
colnames(beep_data)[colnames(beep_data)=="lat"] <- "TagLat"
colnames(beep_data)[colnames(beep_data)=="lng"] <- "TagLng"
pts <- beep_data[!duplicated(beep_data$NodeID),]

freq <- c("3 min", "10 min")
max_nodes <- 0 #how many nodes should be used in the localization calculation?


test <- advanced_resampled_stats(beep_data, nodes, freq = freq[1], keep_cols = c("TagLat", "TagLng"), calibrate = "session_id")
```

    ## [1] "dropped 0 n/a records from 270889 records"

``` r
test$pt <- tags$NodeID[match(test$freq, tags$session_id)]

#pt3 <- test[test$pt==10,]

matchloc <- test[!duplicated(test$freq),]
testloc <- weighted_average(freq = freq[1], beep_data, node = nodes,  calibrate = "session_id", MAX_NODES = 0)
```

    ## [1] "dropped 0 n/a records from 270889 records"
    ## [1] "dropped 0 n/a records from 270889 records"

    ## `summarise()` regrouping output by 'TagId' (override with `.groups` argument)

``` r
testloc$TagLat <- matchloc$TagLat_min[match(testloc$group, matchloc$freq)]
testloc$TagLng <- matchloc$TagLng_min[match(testloc$group, matchloc$freq)]
testloc$pt <- tags$NodeID[match(testloc$group, tags$session_id)]

tag_loc <- matchloc
coordinates(tag_loc) <- ~TagLng_min+TagLat_min
crs(tag_loc) <- CRS("+proj=longlat +datum=WGS84") 
tag_loc <- st_as_sf(tag_loc)

nodes_spatial <- nodes
coordinates(nodes_spatial) <- 3:2

crs(nodes_spatial) <- CRS("+proj=longlat +datum=WGS84") 
my_nodes <- st_as_sf(nodes_spatial)
```

## Plotting

``` r
ggplot() + 
  #geom_point(data=my_locs, aes(x=long,y=lat))
  #  ggmap(ph_basemap) +
  #geom_sf(data = locs, aes(colour=TagId), inherit.aes = FALSE) + 
  geom_sf(data = tag_loc, colour="red") +
  geom_sf(data = my_nodes, colour="blue") +
  geom_text(data = nodes, aes(x=lng, y=lat, label = NodeId)) +
  geom_text(data = pts, aes(x=TagLng, y=TagLat, label = NodeID))
```

![](ABS_calibrationtest_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

``` r
test_loc <- st_as_sf(testloc)

ggplot() + 
  geom_sf(data = test_loc, aes(colour=pt))
```

![](ABS_calibrationtest_files/figure-gfm/unnamed-chunk-2-2.png)<!-- -->

``` r
#test_loc3 <- st_as_sf(pt3_loc)

ggplot() + 
  #geom_point(data=my_locs, aes(x=long,y=lat))
  #  ggmap(ph_basemap) +
  #geom_sf(data = locs, aes(colour=TagId), inherit.aes = FALSE) + 
  geom_text(data = nodes, aes(x=lng, y=lat, label = NodeId), size = 5) +
  #geom_text(data = pts, aes(x=TagLng, y=TagLat, label = Point), size = 5) +
  geom_sf(data = tag_loc, colour="red") +
  geom_sf(data = my_nodes, colour="blue") +
  geom_sf(data = test_loc, aes(colour=pt)) #+
```

![](ABS_calibrationtest_files/figure-gfm/unnamed-chunk-2-3.png)<!-- -->

``` r
  #geom_sf(data = test_loc3, colour="yellow") +
  #geom_text_repel(data = pt3, aes(x=node_lng_min, y=node_lat_min, label = TagRSSI_length, colour=freq))
  #geom_text_repel(data = pt3, aes(x=node_lng_min, y=node_lat_min, label = NodeRSSI_mean, colour=freq))
```
