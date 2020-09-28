Weekly reports
================
9/28/2020

This document is to built to produce weekly reports on **node health**,
**tag localizations**, and the script itself. Script will be updated as
often as upstream (CTT data\_tools) is updated and new features are
added. We are using R linked with GitHub to download the source code,
keep track of updates and changes made on both ends, and share the code
with whoever is interested.

Download all data files (GPS, node health, radiotags) from
<https://account.celltracktech.com/>

Always start the session with `git pull upstream master` in Tools \>
Shell to pull any chances made upstream (CTT data\_tools)

# Analyze data

### Load up our functions into memory

``` r
source("functions/data_manager.R")
source("functions/node_health.R")
```

    ## Loading required package: ggplot2

    ## Loading required package: tidyr

    ## Loading required package: gridExtra

    ## Loading required package: suncalc

    ## Loading required package: geosphere
