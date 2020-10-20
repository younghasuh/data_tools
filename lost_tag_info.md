Tracking specific tags
================
Young Ha Suh

### Load libraries

<br>

### Load data

Load tag data and set variables

``` r
oct19 <- read.csv("../data_tools/datafiles/station_beep_merged_oct19.csv" )
oct19$time <- as.POSIXct(oct19$Time ,format="%m/%d/%Y %H:%M", tz = "UTC")
oct19$time_est <- with_tz(oct19$time, "EST") #change from UTC to EST

# Filter to time points after Oct 17, which is the start of data I downloaded
oct <- oct19 %>% 
  filter(time_est > '2020-10-17 00:00:00')
```

Load node info

``` r
nodes <- read.csv("nodes.csv")
```

<br>

### Data wrangling

Use tidyverse to manipulate data.

``` r
# Need to convert to upper case to left join with the node data
oct$NodeId <- toupper(oct$NodeId)
#table(oct$NodeId) # check if it worked

# Add node numerical ID
oct <- oct %>% 
  left_join(nodes, by = "NodeId")
```

<br>

### Look for rows containing specific tag IDs

Change accordingly

``` r
# Check list of tags detected
# table(oct$TagId)

# set tags
tag1 <- "61342D4C" # -QGA
tag2 <- "342A3478" # -BBX
```

Look for these specific ones

``` r
# Tag 1


tag1data <- oct %>% 
  filter(TagId == tag1) %>% 
  group_by(NodeId) %>% 
  mutate(timeofday = strftime(time_est, format="%H:%M:%S")) %>% 
  arrange(NodeId, -TagRSSI, timeofday) %>% 
  select(NodeId, id, TagRSSI, time_est, timeofday)

tag1data
```

    ## # A tibble: 104 x 5
    ## # Groups:   NodeId [2]
    ##    NodeId    id TagRSSI time_est            timeofday
    ##    <chr>  <int>   <int> <dttm>              <chr>    
    ##  1 425       17    -114 2020-10-17 09:47:00 10:47:00 
    ##  2 425       17    -114 2020-10-17 09:47:00 10:47:00 
    ##  3 425       17    -114 2020-10-17 09:47:00 10:47:00 
    ##  4 425       17    -114 2020-10-17 09:47:00 10:47:00 
    ##  5 425       17    -114 2020-10-17 10:03:00 11:03:00 
    ##  6 425       17    -114 2020-10-17 10:03:00 11:03:00 
    ##  7 425       17    -115 2020-10-17 10:11:00 11:11:00 
    ##  8 425       17    -115 2020-10-17 10:11:00 11:11:00 
    ##  9 425       17    -115 2020-10-17 10:35:00 11:35:00 
    ## 10 425       17    -115 2020-10-17 11:05:00 12:05:00 
    ## # ... with 94 more rows

``` r
# Tag 2
tag2data <- oct %>% 
  filter(TagId == tag2) %>% 
  group_by(NodeId) %>% 
  mutate(timeofday = strftime(time_est, format="%H:%M:%S")) %>% 
  arrange(NodeId, -TagRSSI, timeofday) %>% 
  select(NodeId, id, TagRSSI, time_est, timeofday)

tag2data
```

    ## # A tibble: 12 x 5
    ## # Groups:   NodeId [2]
    ##    NodeId    id TagRSSI time_est            timeofday
    ##    <chr>  <int>   <int> <dttm>              <chr>    
    ##  1 326250   142    -103 2020-10-18 07:33:00 08:33:00 
    ##  2 326250   142    -106 2020-10-18 07:32:00 08:32:00 
    ##  3 326250   142    -106 2020-10-18 07:36:00 08:36:00 
    ##  4 32855D   141     -96 2020-10-18 07:29:00 08:29:00 
    ##  5 32855D   141     -99 2020-10-17 16:44:00 17:44:00 
    ##  6 32855D   141    -101 2020-10-18 07:28:00 08:28:00 
    ##  7 32855D   141    -102 2020-10-17 16:48:00 17:48:00 
    ##  8 32855D   141    -103 2020-10-18 06:57:00 07:57:00 
    ##  9 32855D   141    -105 2020-10-17 16:41:00 17:41:00 
    ## 10 32855D   141    -106 2020-10-17 16:47:00 17:47:00 
    ## 11 32855D   141    -108 2020-10-17 07:17:00 08:17:00 
    ## 12 32855D   141    -109 2020-10-17 07:21:00 08:21:00
