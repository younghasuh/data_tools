library(sf)
library(ggrepel)
library(geosphere)
library(raster)
source("../../data_tools/functions/localization.R")
source("../../data_tools/functions/data_manager.R")
#infile <- "../data/ABS_TagTest1"
#all_data <- load_data(infile) #start_time, end_time tags
setwd("~/Documents/data/archbold/calibration")
beep_data <- read.csv("archbold-calibration-data.csv", as.is=TRUE, na.strings=c("NA", ""))

nodes <- read.csv("archbold-nodes_Young.csv", as.is=TRUE, na.strings=c("NA", ""), strip.white=TRUE) 
nodes$NodeId[8] <- "4D9"
#nodes <- read.csv("NodeLatLong.xlsx - Sheet1.csv", as.is=TRUE, na.strings=c("NA", ""), strip.white=TRUE) #uppercase node letters
#colnames(nodes)[colnames(nodes)=="NodeID"] <- "NodeId"
#colnames(nodes)[colnames(nodes)=="Lat"] <- "lng"
#colnames(nodes)[colnames(nodes)=="Long"] <- "lat"
nodes <- nodes[,c("NodeId", "lat", "lng")]
nodes$NodeId <- toupper(nodes$NodeId)
nodes_spatial <- nodes
coordinates(nodes_spatial) <- 3:2
crs(nodes_spatial) <- CRS("+proj=longlat +datum=WGS84") 

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

plat1 <- c("61335578", "6134074B", "61664C61")
plat2 <- c("6133331E", "61336634", "61526633", "6166194C")
still <- c("61664B1E", "6166194B")
mytags <- c(plat1, plat2, still)
beep_data <- beep_data[beep_data$TagId %in% mytags,]

beep_data$PlatformID <- NA
beep_data$PlatformID[beep_data$TagId %in% still] <- "still"
beep_data$PlatformID[beep_data$TagId %in% plat1] <- "1"
beep_data$PlatformID[beep_data$TagId %in% plat2] <- "2"
beep_data$Time <- as.POSIXct(beep_data$Time, tz = "GMT")
beep_data$time <- beep_data$Time
attributes(beep_data$time)$tzone <- "America/New_York" 

beep_data <- beep_data[!is.na(beep_data$PlatformID),]
beep_data$NodeId <- toupper(beep_data$NodeId)
beep_data <- beep_data[beep_data$NodeId %in% nodes$NodeId,] 

dt1 <- data.table(beep_data, start=beep_data$time, end=beep_data$time)
dt2 <- data.table(tags)
setkey(dt2, PlatformID, start, end)
indx <- foverlaps(dt1, dt2, type='within')
indx <- indx[!is.na(indx$Date),]
indx <- indx[,c("NodeID", "session_id", "Time", "RadioId", "TagId", "TagRSSI", "NodeId")]
indx <- merge(indx, nodes, by.x="NodeID", by.y="NodeId", all.x = TRUE)
colnames(indx)[colnames(indx)=="lat"] <- "TagLat"
colnames(indx)[colnames(indx)=="lng"] <- "TagLng"
colnames(indx)[colnames(indx)=="NodeID"] <- "pt"

ground <- read.csv("CTTgroundtruth_fin.xlsx - survey_0.csv", as.is=TRUE, na.strings=c("NA", ""))
#61524B1E -81.35927 27.19960 2020-02-19 2020-02-19 08:22:00 2020-02-19 08:22:00 AO-X 66
ground$date <- as.Date(ground$Date, format="%m/%d/%y")
ground$start <- as.POSIXct(paste(ground$date, ground$Starting.time), tz="America/New_York")
ground$end <- as.POSIXct(paste(ground$date, ground$End.time), tz="America/New_York")
ground$session_id <- as.integer(rownames(ground)) + max(as.integer(tags$session_id))
colnames(ground)[colnames(ground)=="TagID"] <- "TagId"
ground$pt <- paste(ground$Jay.ID, ground$session_id)

all_data <- load_data("../Archbold/867762040727353/ground")
beep_data <- all_data[[1]][[1]]
beep_data <- beep_data[beep_data$TagId %in% ground$TagId,]
beep_data$time <- beep_data$Time
attributes(beep_data$time)$tzone <- "America/New_York" 
beep_data <- beep_data[beep_data$NodeId %in% nodes$NodeId,] 
#AOX66 <- beep_data[beep_data$time > as.POSIXct("2020-02-19 08:21:59") & beep_data$time < as.POSIXct("2020-02-19 08:23:00"),]
dt1 <- data.table(beep_data, start=beep_data$time, end=beep_data$time)
dt2 <- data.table(ground)
setkey(dt2, TagId, start, end)
indx2 <- foverlaps(dt1, dt2, type='within')
indx2 <- indx2[!is.na(indx2$Date),]
indx2 <- indx2[,c("pt","session_id", "Time", "RadioId", "TagId", "TagRSSI", "NodeId", "y", "x")]
#APX62_merge
colnames(indx2)[colnames(indx2)=="y"] <- "TagLat"
colnames(indx2)[colnames(indx2)=="x"] <- "TagLng"
beep_data <- rbind(indx, indx2)
#beep_data$id <- paste(beep_data$TagId, beep_data$session_id)
beep_data <- as.data.frame(beep_data)

#WHY SO MANY DROPPED RECORDS FROM THE GROUND-TRUTH?
#beep_data <- beep_data[beep_data$PlatformID == "still",] A

freq <- c("3 min", "10 min")
max_nodes <- 0 #how many nodes should be used in the localization calculation?

test <- advanced_resampled_stats(beep_data, nodes, freq = freq[1], keep_cols = c("TagLat", "TagLng", "pt"), calibrate = "session_id")
#test$pt <- test$pt_min

test$id <- paste(test$TagId, test$freq, test$NodeId)
test <- test[order(test$id, -test$TagRSSI_mean, -test$beep_count),]
test <- test[!duplicated(test$id),]
#pt3 <- test[test$pt==10,]

test$groups <- paste(test$TagId, test$freq)
alltags <- test[!duplicated(test$groups),]
pts <- test[!duplicated(test$pt_min),]

tag_loc <- alltags
coordinates(tag_loc) <- ~TagLng_min+TagLat_min
crs(tag_loc) <- CRS("+proj=longlat +datum=WGS84") 

dst <- raster::pointDistance(tag_loc, nodes_spatial, lonlat = T, allpairs = T)
dist_df <- data.frame(dst, row.names = tag_loc$groups)
colnames(dist_df) <- nodes_spatial$NodeId
dist_df$Test.Group <- rownames(dist_df)

# rearrange data
dist.gather <- dist_df %>%
  tidyr::gather(key = "NodeId", value = "distance", -Test.Group)
dist.gather$id <- paste(dist.gather$Test.Group, dist.gather$NodeId)
test$distance <- dist.gather$distance[match(test$id, dist.gather$id)]

plot(TagRSSI_mean ~ distance, data = test)
exp.mod <- nls(TagRSSI_mean ~ SSasymp(distance, Asym, R0, lrc), data = test)
summary(exp.mod)

ggplot(test, aes(x = distance, y = TagRSSI_mean)) + 
  geom_point() +
  stat_smooth(method = "nls", formula = y ~ SSasymp(x, Asym, R0, lrc), se = FALSE, color = "blue") +
  scale_y_continuous(name = "Average RSSI", breaks = c(-110, -100, -90, -80, -70, -60, -50, -40, -30), limits = c(-109,-24)) +
  scale_x_continuous(name = "Distance") +
  #geom_text(x = 1000, y = -30, label = "RSSI = 63.06914 * exp(-0.009777435*distance) + -100.8424 ", size = 3.5) +
  theme_classic()

a <- coef(exp.mod)[["R0"]]
S <- exp(coef(exp.mod)[["lrc"]])
K <- coef(exp.mod)[["Asym"]]

all_data <- data.frame(TagId = test$TagId, NodeId = test$NodeId, long = test$node_lng_min, lat = test$node_lat_min, avg.RSSI = test$TagRSSI_mean, Test.Group = paste(test$TagId, test$freq))
test.g90.dat <- all_data[all_data$avg.RSSI > -100,]
sample.size <- test.g90.dat %>%
  dplyr::group_by(Test.Group) %>%
  dplyr::summarise(n.nodes = n()) %>%
  dplyr::filter(n.nodes < 3)
test.red.dat <- test.g90.dat[!test.g90.dat$Test.Group %in% sample.size$Test.Group,]
#K = -100.8424
#a = -63.06914
#S = 0.009777435
test.red.dat$dist.est = abs(log((test.red.dat$avg.RSSI - K)/abs(a))/S) #changed sign on S despite relationship in Paxton's original script
estimated.location_results <- data.frame(Test.Group=character(), long.est=numeric(), lat.est=numeric(), est.error =numeric())
tests = unique(test.red.dat$Test.Group)
for(j in 1:length(tests)) {
  
  # Isolate the test 
  sub.test <- test.red.dat %>% dplyr::filter(Test.Group == tests[j]) 
  
  # Determine the node with the strongest avg.RSSI value to be used as starting values
  max.RSSI <- sub.test[which.max(sub.test$avg.RSSI),]
  print(j)
  # Non-linear test to optimize the location of unknown signal by looking at the radius around each Node based on RSSI values (distance) and the pairwise distance between all nodes
  nls.test <- nls(dist.est ~ geosphere::distm(data.frame(long, lat), c(lng_solution, lat_solution), fun=distHaversine), # distm - matrix of pairwise distances between lat/longs
                  data = sub.test, start=list(lng_solution=max.RSSI$long, lat_solution=max.RSSI$lat), # used long/lat of NodeId with largest RSSI identified in max.RSSI
                  control=nls.control(warnOnly = T, minFactor=1/30000)) # gives a warning, but doesn't stop the test from providing an estimate based on the last iteration before the warning
  
  # Determine error around the point location estimate
  c <- car::confidenceEllipse(nls.test, levels=0.95) 
  ellipse_line <- c[1, ] # isolating one point on the line 
  ellipse_line <- rbind(ellipse_line, coef(nls.test)) # bringing together the one isolated point on the line and the estimated point - coef(nls.test)
  est.error <-(distm(ellipse_line[1,], ellipse_line[2,]))
  
  # estimated location of the test and error
  estimated.loc <- data.frame(Test.Group = tests[j], long.est = ellipse_line[2,1], lat.est = ellipse_line[2,2], est.error = est.error)
  
  # Populate dataframe with results
  estimated.location_results <- rbind(estimated.location_results, estimated.loc)
  
}

lessinfo <- beep_data[paste(beep_data$TagId, beep_data$session_id) %in% sample.size$Test.Group,]
testloc <- weighted_average(freq = freq[1], lessinfo, node = nodes,  calibrate = "session_id", MAX_NODES = 0)

lessnodes <- data.frame(Test.Group = testloc@data$id, long.est = testloc@coords[,1], lat.est = testloc@coords[,2], est.error = NA)

#estimated.location_results <- rbind(estimated.location_results, lessnodes)

estimated.location_results$session_id <- sapply(strsplit(as.character(estimated.location_results$Test.Group), " "), "[[", 2)
estimated.location_results$pt <- test$pt_min[match(estimated.location_results$session_id, test$freq)]

coordinates(estimated.location_results) <- 2:3
crs(estimated.location_results) <- CRS("+proj=longlat +datum=WGS84") 

tag_loc <- st_as_sf(tag_loc)
my_nodes <- st_as_sf(nodes_spatial)

ggplot() + 
  #geom_point(data=my_locs, aes(x=long,y=lat))
  #  ggmap(ph_basemap) +
  #geom_sf(data = locs, aes(colour=TagId), inherit.aes = FALSE) + 
  geom_sf(data = tag_loc, colour="red") +
  geom_sf(data = my_nodes, colour="blue") +
  geom_text(data = nodes, aes(x=lng, y=lat, label = NodeId)) #+
  #geom_text(data = pts, aes(x=TagLng, y=TagLat, label = NodeID))

test_loc <- st_as_sf(estimated.location_results)

ggplot() + 
  geom_sf(data = test_loc, aes(colour=pt))

#test_loc3 <- st_as_sf(pt3_loc)

ggplot() + 
  #geom_point(data=my_locs, aes(x=long,y=lat))
  #  ggmap(ph_basemap) +
  #geom_sf(data = locs, aes(colour=TagId), inherit.aes = FALSE) + 
  geom_text_repel(data = ground, aes(x=x, y=y, label = pt)) +
  geom_text(data = nodes, aes(x=lng, y=lat, label = NodeId), size = 5) +
  #geom_text(data = pts, aes(x=TagLng_min, y=TagLat_min, label = pt_min), size = 5) +
  geom_sf(data = tag_loc, colour="red") +
  geom_sf(data = my_nodes, colour="blue") +
  geom_sf(data = test_loc, aes(colour=pt)) #+
  #geom_sf(data = test_loc3, colour="yellow") +
  #geom_text_repel(data = pt3, aes(x=node_lng_min, y=node_lat_min, label = TagRSSI_length, colour=freq))
  #geom_text_repel(data = pt3, aes(x=node_lng_min, y=node_lat_min, label = NodeRSSI_mean, colour=freq))
