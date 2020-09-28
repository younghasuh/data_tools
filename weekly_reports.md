Weekly reports
================
Young Ha Suh
9/28/2020

This document is to built to produce weekly reports on **node health**,
**tag localizations**, and the script itself for Archbold Biological
Station. Script will be updated as often as upstream (CTT data\_tools)
is updated and new features are added. We are using R linked with GitHub
to download the source code, keep track of updates and changes made on
both ends, and share the code with whoever is interested. The original
code is from Dr. Jessica Gorzo (<jessica.gorzo@celltracktech.com>).

Download all data files (GPS, node health, beep data) from
<https://account.celltracktech.com/>

Always start the session with `git pull upstream master` in Tools \>
Shell to pull any chances made upstream (CTT data\_tools)

# Analyze data

### Load up our functions into memory

    ## Loading required package: ggplot2

    ## Loading required package: tidyr

    ## Loading required package: gridExtra

    ## Loading required package: suncalc

    ## Loading required package: geosphere

### Set up

Infile needs to be updated based on data that has been downloaded from
CTT account weekly.

``` r
infile <- "../data_tools/datafiles/Sep22-28/" 

#This is where you want your output to go
outpath <- "../plots/"

freq <- "1 hour" 
```
