Weekly reports for Archbold
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

# Add weekly raw data

Data will need to be downloaded from the CTT account. *Need to figure
out how to do this more easily because clicking download 150 x 3 times
is not fun*

Put all files into their own folder in `data_tools > datafiles > [date]`

To commit all those at once, type in shell:  
`git add .` : add all changes  
`git commit -m "MESSAGE here"` : commit them  
`git push origin master` : push committed changes from local to remote
repository

May take a hot second. Refresh github page to see if data was uploaded.

# Code for analyzing data

### Load up our functions into memory

``` r
source("functions/data_manager.R")
source("functions/node_health.R")
library(readxl)
```

### Set up

Infile needs to be updated based on data that has been downloaded from
CTT account weekly. Set time accordingly.

``` r
infile <- "../data_tools/datafiles/Sep22-28/" 

#This is where you want your output to go
outpath <- "../plots/"

#Set frequency
freq <- "10 minutes" 

#Set time (example)
start_time = as.POSIXct("2020-09-22 01:00:00", tz = "America/New_York")
end_time = as.POSIXct("2020-09-28 20:00:00", tz = "America/New_York")

all_data <- load_data(infile)
```

    ## [1] "preparing 150 beep files for merge from ../data_tools/datafiles/Sep22-28/ using the regex ^(?=.*data)(?!.*(node|log|gps))"
    ## [1] "beep"
    ##   [1] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_175150.csv.gz"    
    ##   [2] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_185150.csv.gz"    
    ##   [3] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_195151.csv.gz"    
    ##   [4] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_205152.csv.gz"    
    ##   [5] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_215153.csv.gz"    
    ##   [6] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_225153.csv.gz"    
    ##   [7] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_235154.csv.gz"    
    ##   [8] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_005155.csv.gz"    
    ##   [9] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_015156.csv.gz"    
    ##  [10] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_025157.csv.gz"    
    ##  [11] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_035158.csv.gz"    
    ##  [12] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_045200.csv.gz"    
    ##  [13] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_055201.csv.gz"    
    ##  [14] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_065202.csv.gz"    
    ##  [15] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_075203.csv.gz"    
    ##  [16] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_085204.csv.gz"    
    ##  [17] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_095205.csv.gz"    
    ##  [18] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_105206.csv.gz"    
    ##  [19] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_115207.csv.gz"    
    ##  [20] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_125209.csv.gz"    
    ##  [21] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_135209.csv.gz"    
    ##  [22] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_145210.csv.gz"    
    ##  [23] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_155211.csv.gz"    
    ##  [24] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_165211.csv.gz"    
    ##  [25] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_175212.csv.gz"    
    ##  [26] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_185213.csv.gz"    
    ##  [27] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_195214.csv.gz"    
    ##  [28] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_205214.csv.gz"    
    ##  [29] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_215215.csv.gz"    
    ##  [30] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_225215.csv.gz"    
    ##  [31] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_235216.csv.gz"    
    ##  [32] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_005217.csv.gz"    
    ##  [33] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_015219.csv.gz"    
    ##  [34] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_025220.csv.gz"    
    ##  [35] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_035221.csv.gz"    
    ##  [36] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_045222.csv.gz"    
    ##  [37] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_055223.csv.gz"    
    ##  [38] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_065224.csv.gz"    
    ##  [39] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_075225.csv.gz"    
    ##  [40] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_085226.csv.gz"    
    ##  [41] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_095227.csv.gz"    
    ##  [42] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_105229.csv.gz"    
    ##  [43] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_115230.csv.gz"    
    ##  [44] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_125231.csv.gz"    
    ##  [45] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_135232.csv.gz"    
    ##  [46] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_145232.csv.gz"    
    ##  [47] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_155233.csv.gz"    
    ##  [48] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_165234.csv.gz"    
    ##  [49] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_175234.csv.gz"    
    ##  [50] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235 (1).csv.gz"
    ##  [51] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235.csv.gz"    
    ##  [52] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_195236.csv.gz"    
    ##  [53] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_205236.csv.gz"    
    ##  [54] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_215237.csv.gz"    
    ##  [55] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_225238.csv.gz"    
    ##  [56] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_235239.csv.gz"    
    ##  [57] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_005240.csv.gz"    
    ##  [58] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_015241.csv.gz"    
    ##  [59] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_025242.csv.gz"    
    ##  [60] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_035243.csv.gz"    
    ##  [61] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_045244.csv.gz"    
    ##  [62] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_055245.csv.gz"    
    ##  [63] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_065246.csv.gz"    
    ##  [64] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_075248.csv.gz"    
    ##  [65] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_085249.csv.gz"    
    ##  [66] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_095250.csv.gz"    
    ##  [67] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_105251.csv.gz"    
    ##  [68] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_115252.csv.gz"    
    ##  [69] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_125253.csv.gz"    
    ##  [70] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_135254.csv.gz"    
    ##  [71] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_145254.csv.gz"    
    ##  [72] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_155255.csv.gz"    
    ##  [73] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_165256.csv.gz"    
    ##  [74] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_175256.csv.gz"    
    ##  [75] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_185257.csv.gz"    
    ##  [76] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_195258.csv.gz"    
    ##  [77] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_205258.csv.gz"    
    ##  [78] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_215259.csv.gz"    
    ##  [79] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_225300.csv.gz"    
    ##  [80] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_235301.csv.gz"    
    ##  [81] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_005302.csv.gz"    
    ##  [82] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_015303.csv.gz"    
    ##  [83] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_025304.csv.gz"    
    ##  [84] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_035305.csv.gz"    
    ##  [85] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_045306.csv.gz"    
    ##  [86] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_055308.csv.gz"    
    ##  [87] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_065309.csv.gz"    
    ##  [88] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_075310.csv.gz"    
    ##  [89] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_085311.csv.gz"    
    ##  [90] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_095312.csv.gz"    
    ##  [91] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_105313.csv.gz"    
    ##  [92] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_115315.csv.gz"    
    ##  [93] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_125316.csv.gz"    
    ##  [94] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_135316.csv.gz"    
    ##  [95] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_145317.csv.gz"    
    ##  [96] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_155318.csv.gz"    
    ##  [97] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_165318.csv.gz"    
    ##  [98] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_175319.csv.gz"    
    ##  [99] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_185320.csv.gz"    
    ## [100] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_195321.csv.gz"    
    ## [101] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_205321.csv.gz"    
    ## [102] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_215322.csv.gz"    
    ## [103] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_225323.csv.gz"    
    ## [104] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_235323.csv.gz"    
    ## [105] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_005324.csv.gz"    
    ## [106] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_015326.csv.gz"    
    ## [107] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_025327.csv.gz"    
    ## [108] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_035328.csv.gz"    
    ## [109] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_045329.csv.gz"    
    ## [110] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_055330.csv.gz"    
    ## [111] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_065331.csv.gz"    
    ## [112] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_075332.csv.gz"    
    ## [113] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_085334.csv.gz"    
    ## [114] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_095335.csv.gz"    
    ## [115] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_105336.csv.gz"    
    ## [116] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_115337.csv.gz"    
    ## [117] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_125338.csv.gz"    
    ## [118] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_135338.csv.gz"    
    ## [119] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_145339.csv.gz"    
    ## [120] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_155340.csv.gz"    
    ## [121] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_165340.csv.gz"    
    ## [122] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_175341.csv.gz"    
    ## [123] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_185342.csv.gz"    
    ## [124] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_195342.csv.gz"    
    ## [125] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_205343.csv.gz"    
    ## [126] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_215344.csv.gz"    
    ## [127] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_225345.csv.gz"    
    ## [128] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_235346.csv.gz"    
    ## [129] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_005347.csv.gz"    
    ## [130] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_015348.csv.gz"    
    ## [131] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_025349.csv.gz"    
    ## [132] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_035350.csv.gz"    
    ## [133] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_045351.csv.gz"    
    ## [134] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_055352.csv.gz"    
    ## [135] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_065353.csv.gz"    
    ## [136] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_075355.csv.gz"    
    ## [137] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_085356.csv.gz"    
    ## [138] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_095357.csv.gz"    
    ## [139] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_105358.csv.gz"    
    ## [140] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_115359.csv.gz"    
    ## [141] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_125400.csv.gz"    
    ## [142] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_135401.csv.gz"    
    ## [143] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_145402.csv.gz"    
    ## [144] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_155402.csv.gz"    
    ## [145] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_165403.csv.gz"    
    ## [146] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_175404.csv.gz"    
    ## [147] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_185404.csv.gz"    
    ## [148] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_195405.csv.gz"    
    ## [149] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_205406.csv.gz"    
    ## [150] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_215406.csv.gz"    
    ## [1] "beep"
    ## NULL
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_175150.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_185150.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_195151.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_205152.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_215153.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_225153.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_235154.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_005155.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_015156.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_025157.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_035158.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_045200.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_055201.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_065202.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_075203.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_085204.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_095205.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_105206.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_115207.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_125209.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_135209.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_145210.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_155211.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_165211.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_175212.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_185213.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_195214.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_205214.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_215215.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_225215.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_235216.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_005217.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_015219.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_025220.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_035221.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_045222.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_055223.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_065224.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_075225.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_085226.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_095227.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_105229.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_115230.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_125231.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_135232.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_145232.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_155233.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_165234.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_175234.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235 (1).csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_195236.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_205236.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_215237.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_225238.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_235239.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_005240.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_015241.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_025242.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_035243.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_045244.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_055245.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_065246.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_075248.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_085249.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_095250.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_105251.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_115252.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_125253.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_135254.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_145254.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_155255.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_165256.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_175256.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_185257.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_195258.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_205258.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_215259.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_225300.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_235301.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_005302.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_015303.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_025304.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_035305.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_045306.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_055308.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_065309.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_075310.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_085311.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_095312.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_105313.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_115315.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_125316.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_135316.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_145317.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_155318.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_165318.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_175319.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_185320.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_195321.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_205321.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_215322.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_225323.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_235323.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_005324.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_015326.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_025327.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_035328.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_045329.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_055330.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_065331.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_075332.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_085334.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_095335.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_105336.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_115337.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_125338.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_135338.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_145339.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_155340.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_165340.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_175341.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_185342.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_195342.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_205343.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_215344.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_225345.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_235346.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_005347.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_015348.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_025349.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_035350.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_045351.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_055352.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_065353.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_075355.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_085356.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_095357.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_105358.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_115359.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_125400.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_135401.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_145402.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_155402.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_165403.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_175404.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_185404.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_195405.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_205406.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_215406.csv.gz"
    ## [1] 2
    ## [1] "preparing 147 node health files for merge"
    ## [1] "node"
    ##   [1] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_175150.csv.gz"
    ##   [2] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_185151.csv.gz"
    ##   [3] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_195152.csv.gz"
    ##   [4] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_205152.csv.gz"
    ##   [5] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_215153.csv.gz"
    ##   [6] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_225154.csv.gz"
    ##   [7] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_235155.csv.gz"
    ##   [8] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_005155.csv.gz"
    ##   [9] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_015157.csv.gz"
    ##  [10] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_025157.csv.gz"
    ##  [11] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_035159.csv.gz"
    ##  [12] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_045200.csv.gz"
    ##  [13] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_055201.csv.gz"
    ##  [14] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_065202.csv.gz"
    ##  [15] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_075203.csv.gz"
    ##  [16] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_085204.csv.gz"
    ##  [17] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_095205.csv.gz"
    ##  [18] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_105207.csv.gz"
    ##  [19] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_115208.csv.gz"
    ##  [20] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_125209.csv.gz"
    ##  [21] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_135210.csv.gz"
    ##  [22] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_145211.csv.gz"
    ##  [23] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_155211.csv.gz"
    ##  [24] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_165212.csv.gz"
    ##  [25] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_175213.csv.gz"
    ##  [26] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_185213.csv.gz"
    ##  [27] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_195214.csv.gz"
    ##  [28] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_215215.csv.gz"
    ##  [29] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_225216.csv.gz"
    ##  [30] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_235217.csv.gz"
    ##  [31] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_005218.csv.gz"
    ##  [32] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_015219.csv.gz"
    ##  [33] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_025220.csv.gz"
    ##  [34] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_035221.csv.gz"
    ##  [35] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_045222.csv.gz"
    ##  [36] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_055223.csv.gz"
    ##  [37] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_065224.csv.gz"
    ##  [38] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_075226.csv.gz"
    ##  [39] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_085227.csv.gz"
    ##  [40] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_095228.csv.gz"
    ##  [41] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_105229.csv.gz"
    ##  [42] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_115230.csv.gz"
    ##  [43] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_125231.csv.gz"
    ##  [44] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_135232.csv.gz"
    ##  [45] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_145233.csv.gz"
    ##  [46] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_155234.csv.gz"
    ##  [47] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_165234.csv.gz"
    ##  [48] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_175235.csv.gz"
    ##  [49] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_185236.csv.gz"
    ##  [50] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_195236.csv.gz"
    ##  [51] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_205237.csv.gz"
    ##  [52] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_215238.csv.gz"
    ##  [53] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_225238.csv.gz"
    ##  [54] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_235239.csv.gz"
    ##  [55] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_005240.csv.gz"
    ##  [56] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_015241.csv.gz"
    ##  [57] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_025242.csv.gz"
    ##  [58] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_035243.csv.gz"
    ##  [59] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_045244.csv.gz"
    ##  [60] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_055245.csv.gz"
    ##  [61] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_065246.csv.gz"
    ##  [62] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_075248.csv.gz"
    ##  [63] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_085249.csv.gz"
    ##  [64] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_095250.csv.gz"
    ##  [65] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_105251.csv.gz"
    ##  [66] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_115252.csv.gz"
    ##  [67] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_135254.csv.gz"
    ##  [68] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_145255.csv.gz"
    ##  [69] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_155255.csv.gz"
    ##  [70] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_165256.csv.gz"
    ##  [71] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_175257.csv.gz"
    ##  [72] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_185258.csv.gz"
    ##  [73] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_195258.csv.gz"
    ##  [74] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_205259.csv.gz"
    ##  [75] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_215300.csv.gz"
    ##  [76] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_225300.csv.gz"
    ##  [77] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_235301.csv.gz"
    ##  [78] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_005302.csv.gz"
    ##  [79] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_015303.csv.gz"
    ##  [80] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_025304.csv.gz"
    ##  [81] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_035305.csv.gz"
    ##  [82] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_045307.csv.gz"
    ##  [83] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_055308.csv.gz"
    ##  [84] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_065309.csv.gz"
    ##  [85] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_075310.csv.gz"
    ##  [86] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_085311.csv.gz"
    ##  [87] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_095312.csv.gz"
    ##  [88] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_105314.csv.gz"
    ##  [89] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_115315.csv.gz"
    ##  [90] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_125316.csv.gz"
    ##  [91] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_135317.csv.gz"
    ##  [92] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_145318.csv.gz"
    ##  [93] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_155318.csv.gz"
    ##  [94] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_165319.csv.gz"
    ##  [95] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_175320.csv.gz"
    ##  [96] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_185321.csv.gz"
    ##  [97] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_195321.csv.gz"
    ##  [98] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_205322.csv.gz"
    ##  [99] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_215322.csv.gz"
    ## [100] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_225323.csv.gz"
    ## [101] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_235324.csv.gz"
    ## [102] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_005325.csv.gz"
    ## [103] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_015326.csv.gz"
    ## [104] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_025327.csv.gz"
    ## [105] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_035328.csv.gz"
    ## [106] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_045329.csv.gz"
    ## [107] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_055330.csv.gz"
    ## [108] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_065331.csv.gz"
    ## [109] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_075333.csv.gz"
    ## [110] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_085334.csv.gz"
    ## [111] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_095335.csv.gz"
    ## [112] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_105336.csv.gz"
    ## [113] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_115337.csv.gz"
    ## [114] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_135339.csv.gz"
    ## [115] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_145340.csv.gz"
    ## [116] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_155340.csv.gz"
    ## [117] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_165341.csv.gz"
    ## [118] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_175342.csv.gz"
    ## [119] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_185342.csv.gz"
    ## [120] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_195343.csv.gz"
    ## [121] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_205344.csv.gz"
    ## [122] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_215344.csv.gz"
    ## [123] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_225345.csv.gz"
    ## [124] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_235346.csv.gz"
    ## [125] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_005347.csv.gz"
    ## [126] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_015348.csv.gz"
    ## [127] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_025349.csv.gz"
    ## [128] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_035350.csv.gz"
    ## [129] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_045351.csv.gz"
    ## [130] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_055352.csv.gz"
    ## [131] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_065354.csv.gz"
    ## [132] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_075355.csv.gz"
    ## [133] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_085356.csv.gz"
    ## [134] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_095357.csv.gz"
    ## [135] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_105358.csv.gz"
    ## [136] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_115359.csv.gz"
    ## [137] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_125401.csv.gz"
    ## [138] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_135401.csv.gz"
    ## [139] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_145402.csv.gz"
    ## [140] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_155403.csv.gz"
    ## [141] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_165404.csv.gz"
    ## [142] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_175404.csv.gz"
    ## [143] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_185405.csv.gz"
    ## [144] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_195406.csv.gz"
    ## [145] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_205406.csv.gz"
    ## [146] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_215407.csv.gz"
    ## [147] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_225407.csv.gz"
    ## [1] "node"
    ## NULL
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_175150.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 158 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_185151.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_195152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 134 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_205152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 113 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_215153.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 100 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_225154.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_235155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 183 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_005155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_015157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 239 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_025157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 239 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_035159.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 238 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_045200.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_055201.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_065202.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_075203.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 226 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_085204.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_095205.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_105207.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 237 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_115208.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_125209.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 212 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_135210.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 146 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_145211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 106 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_155211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 100 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_165212.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 108 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_175213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 123 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_185213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 120 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_195214.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 104 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_215215.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 116 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_225216.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 113 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_235217.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 161 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_005218.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 244 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_015219.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 233 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_025220.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 225 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_035221.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 234 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_045222.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 230 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_055223.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_065224.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 231 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_075226.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 219 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_085227.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 209 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_095228.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 222 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_105229.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 219 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_115230.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 218 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_125231.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_135232.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 142 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_145233.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 108 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_155234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 124 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_165234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 107 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_175235.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 106 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_185236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 114 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_195236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 110 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_205237.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 104 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_215238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 109 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_225238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 127 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_235239.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 179 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_005240.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_015241.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_025242.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_035243.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_045244.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_055245.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 222 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_065246.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_075248.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_085249.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 211 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_095250.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 208 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_105251.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 201 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_115252.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_135254.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 181 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_145255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 134 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_155255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 128 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_165256.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 96 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_175257.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 130 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_185258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 90 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_195258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 94 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_205259.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 94 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_215300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 102 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_225300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 122 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_235301.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 195 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_005302.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 205 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_015303.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 198 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_025304.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 198 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_035305.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_045307.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 211 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_055308.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 226 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_065309.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 229 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_075310.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_085311.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 232 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_095312.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_105314.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_115315.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 228 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_125316.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_135317.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 158 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_145318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 118 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_155318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 103 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_165319.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 119 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_175320.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 95 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_185321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 85 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_195321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 97 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_205322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_215322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 115 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_225323.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 99 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_235324.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 151 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_005325.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 231 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_015326.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 252 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_025327.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_035328.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 218 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_045329.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 226 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_055330.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_065331.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 244 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_075333.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_085334.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_095335.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 225 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_105336.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_115337.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 201 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_135339.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 93 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_145340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 108 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_155340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 88 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_165341.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 81 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_175342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 82 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_185342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 100 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_195343.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 86 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_205344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 105 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_215344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 98 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_225345.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_235346.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 205 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_005347.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 225 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_015348.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 228 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_025349.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_035350.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_045351.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_055352.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_065354.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_075355.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_085356.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_095357.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_105358.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_115359.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_125401.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 215 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_135401.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 178 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_145402.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 87 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_155403.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 114 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_165404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 103 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_175404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 105 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_185405.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 106 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_195406.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 91 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_205406.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 83 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_215407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 161 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_225407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 173 bad time format records"
    ## [1] "preparing 148 gps files for merge"
    ## [1] "gps"
    ##   [1] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_175150.csv.gz"
    ##   [2] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_185151.csv.gz"
    ##   [3] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_195152.csv.gz"
    ##   [4] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_205152.csv.gz"
    ##   [5] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_215153.csv.gz"
    ##   [6] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_225154.csv.gz"
    ##   [7] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_235155.csv.gz"
    ##   [8] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_005155.csv.gz"
    ##   [9] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_015157.csv.gz"
    ##  [10] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_025157.csv.gz"
    ##  [11] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_035159.csv.gz"
    ##  [12] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_045200.csv.gz"
    ##  [13] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_055201.csv.gz"
    ##  [14] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_065202.csv.gz"
    ##  [15] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_075203.csv.gz"
    ##  [16] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_085204.csv.gz"
    ##  [17] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_095205.csv.gz"
    ##  [18] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_105207.csv.gz"
    ##  [19] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_115208.csv.gz"
    ##  [20] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_125209.csv.gz"
    ##  [21] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_135210.csv.gz"
    ##  [22] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_145211.csv.gz"
    ##  [23] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_155211.csv.gz"
    ##  [24] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_165212.csv.gz"
    ##  [25] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_175213.csv.gz"
    ##  [26] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_185213.csv.gz"
    ##  [27] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_195214.csv.gz"
    ##  [28] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_205215.csv.gz"
    ##  [29] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_215215.csv.gz"
    ##  [30] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_225216.csv.gz"
    ##  [31] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_235217.csv.gz"
    ##  [32] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_005218.csv.gz"
    ##  [33] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_015219.csv.gz"
    ##  [34] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_025220.csv.gz"
    ##  [35] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_035221.csv.gz"
    ##  [36] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_045222.csv.gz"
    ##  [37] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_055223.csv.gz"
    ##  [38] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_065224.csv.gz"
    ##  [39] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_075226.csv.gz"
    ##  [40] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_085226.csv.gz"
    ##  [41] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_095228.csv.gz"
    ##  [42] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_105229.csv.gz"
    ##  [43] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_115230.csv.gz"
    ##  [44] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_125231.csv.gz"
    ##  [45] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_135232.csv.gz"
    ##  [46] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_145233.csv.gz"
    ##  [47] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_155234.csv.gz"
    ##  [48] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_165234.csv.gz"
    ##  [49] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_175235.csv.gz"
    ##  [50] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_185236.csv.gz"
    ##  [51] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_195236.csv.gz"
    ##  [52] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_205237.csv.gz"
    ##  [53] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_215238.csv.gz"
    ##  [54] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_225238.csv.gz"
    ##  [55] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_235239.csv.gz"
    ##  [56] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_005240.csv.gz"
    ##  [57] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_015241.csv.gz"
    ##  [58] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_025242.csv.gz"
    ##  [59] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_035243.csv.gz"
    ##  [60] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_045244.csv.gz"
    ##  [61] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_055245.csv.gz"
    ##  [62] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_065246.csv.gz"
    ##  [63] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_075248.csv.gz"
    ##  [64] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_085249.csv.gz"
    ##  [65] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_095250.csv.gz"
    ##  [66] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_105251.csv.gz"
    ##  [67] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_115252.csv.gz"
    ##  [68] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_125253.csv.gz"
    ##  [69] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_135254.csv.gz"
    ##  [70] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_145255.csv.gz"
    ##  [71] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_155255.csv.gz"
    ##  [72] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_165256.csv.gz"
    ##  [73] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_175257.csv.gz"
    ##  [74] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_185258.csv.gz"
    ##  [75] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_195258.csv.gz"
    ##  [76] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_205259.csv.gz"
    ##  [77] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_215300.csv.gz"
    ##  [78] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_225300.csv.gz"
    ##  [79] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_235301.csv.gz"
    ##  [80] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_005302.csv.gz"
    ##  [81] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_015303.csv.gz"
    ##  [82] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_025304.csv.gz"
    ##  [83] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_035305.csv.gz"
    ##  [84] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_045307.csv.gz"
    ##  [85] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_055308.csv.gz"
    ##  [86] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_065309.csv.gz"
    ##  [87] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_075310.csv.gz"
    ##  [88] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_085311.csv.gz"
    ##  [89] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_095312.csv.gz"
    ##  [90] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_105314.csv.gz"
    ##  [91] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_115315.csv.gz"
    ##  [92] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_125316.csv.gz"
    ##  [93] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_135317.csv.gz"
    ##  [94] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_145318.csv.gz"
    ##  [95] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_155318.csv.gz"
    ##  [96] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_165319.csv.gz"
    ##  [97] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_175320.csv.gz"
    ##  [98] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_185321.csv.gz"
    ##  [99] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_195321.csv.gz"
    ## [100] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_205322.csv.gz"
    ## [101] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_215322.csv.gz"
    ## [102] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_225323.csv.gz"
    ## [103] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_235324.csv.gz"
    ## [104] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_005325.csv.gz"
    ## [105] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_015326.csv.gz"
    ## [106] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_025327.csv.gz"
    ## [107] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_035328.csv.gz"
    ## [108] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_045329.csv.gz"
    ## [109] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_055330.csv.gz"
    ## [110] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_065331.csv.gz"
    ## [111] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_075333.csv.gz"
    ## [112] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_085334.csv.gz"
    ## [113] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_095335.csv.gz"
    ## [114] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_105336.csv.gz"
    ## [115] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_115337.csv.gz"
    ## [116] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_125338.csv.gz"
    ## [117] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_135339.csv.gz"
    ## [118] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_145340.csv.gz"
    ## [119] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_155340.csv.gz"
    ## [120] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_165341.csv.gz"
    ## [121] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_175342.csv.gz"
    ## [122] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_185342.csv.gz"
    ## [123] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_195343.csv.gz"
    ## [124] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_205344.csv.gz"
    ## [125] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_215344.csv.gz"
    ## [126] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_225345.csv.gz"
    ## [127] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_235346.csv.gz"
    ## [128] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_005347.csv.gz"
    ## [129] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_015348.csv.gz"
    ## [130] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_025349.csv.gz"
    ## [131] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_035350.csv.gz"
    ## [132] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_045351.csv.gz"
    ## [133] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_055352.csv.gz"
    ## [134] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_065354.csv.gz"
    ## [135] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_075355.csv.gz"
    ## [136] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_085356.csv.gz"
    ## [137] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_095357.csv.gz"
    ## [138] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_105358.csv.gz"
    ## [139] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_125400.csv.gz"
    ## [140] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_135401.csv.gz"
    ## [141] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_145402.csv.gz"
    ## [142] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_155403.csv.gz"
    ## [143] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_165404.csv.gz"
    ## [144] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_175404.csv.gz"
    ## [145] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_185405.csv.gz"
    ## [146] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_205406.csv.gz"
    ## [147] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_215407.csv.gz"
    ## [148] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_225407.csv.gz"
    ## [1] "gps"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_175150.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_185151.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_195152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_205152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_215153.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_225154.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_235155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_005155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_015157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_025157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_035159.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_045200.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_055201.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_065202.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_075203.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_085204.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_095205.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_105207.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_115208.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_125209.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_135210.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_145211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_155211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_165212.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_175213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_185213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_195214.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_205215.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_215215.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_225216.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_235217.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_005218.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_015219.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_025220.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_035221.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_045222.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_055223.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_065224.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_075226.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_085226.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_095228.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_105229.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_115230.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_125231.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_135232.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_145233.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_155234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_165234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_175235.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_185236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_195236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_205237.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_215238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_225238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_235239.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_005240.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_015241.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_025242.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_035243.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_045244.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_055245.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_065246.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_075248.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_085249.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_095250.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_105251.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_115252.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_125253.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_135254.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_145255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_155255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_165256.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_175257.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_185258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_195258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_205259.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_215300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_225300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_235301.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_005302.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_015303.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_025304.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_035305.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_045307.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_055308.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_065309.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_075310.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_085311.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_095312.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_105314.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_115315.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_125316.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_135317.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_145318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_155318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_165319.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_175320.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_185321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_195321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_205322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_215322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_225323.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_235324.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_005325.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_015326.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_025327.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_035328.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_045329.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_055330.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_065331.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_075333.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_085334.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_095335.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_105336.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_115337.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_125338.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_135339.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_145340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_155340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_165341.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_175342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_185342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_195343.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_205344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_215344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_225345.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_235346.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_005347.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_015348.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_025349.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_035350.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_045351.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_055352.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_065354.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_075355.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_085356.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_095357.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_105358.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_125400.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_135401.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_145402.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_155403.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_165404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_175404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_185405.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_205406.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_215407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_225407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2

#### Tags

Get a vector of tag list. Download from Nest Matrix use following. The
only part that needs to be edited before getting loaded here is removing
the space between Tag and ID before importing it.

``` r
#Extract list of tags
list <- read_excel("tags.xlsx")

#create a left function in r
left = function (string,char) {
    substr(string,1,char)
}
list$tagid <- left(list$TagID, 8) #only the first 8 characters are read as tag ID

#list will serve as a reference to jayID - tagID

#Extract tags as vector
tags <- as.vector(list$tagid)

#Subset tags of interest if needed
#subtags <- c("33550752", "3334551E")
```

#### Merge file and extract relevant information

This takes a while to run.

``` r
all_data <- load_data(infile) #start_time, end_time, tags
```

    ## [1] "preparing 150 beep files for merge from ../data_tools/datafiles/Sep22-28/ using the regex ^(?=.*data)(?!.*(node|log|gps))"
    ## [1] "beep"
    ##   [1] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_175150.csv.gz"    
    ##   [2] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_185150.csv.gz"    
    ##   [3] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_195151.csv.gz"    
    ##   [4] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_205152.csv.gz"    
    ##   [5] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_215153.csv.gz"    
    ##   [6] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_225153.csv.gz"    
    ##   [7] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_235154.csv.gz"    
    ##   [8] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_005155.csv.gz"    
    ##   [9] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_015156.csv.gz"    
    ##  [10] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_025157.csv.gz"    
    ##  [11] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_035158.csv.gz"    
    ##  [12] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_045200.csv.gz"    
    ##  [13] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_055201.csv.gz"    
    ##  [14] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_065202.csv.gz"    
    ##  [15] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_075203.csv.gz"    
    ##  [16] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_085204.csv.gz"    
    ##  [17] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_095205.csv.gz"    
    ##  [18] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_105206.csv.gz"    
    ##  [19] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_115207.csv.gz"    
    ##  [20] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_125209.csv.gz"    
    ##  [21] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_135209.csv.gz"    
    ##  [22] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_145210.csv.gz"    
    ##  [23] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_155211.csv.gz"    
    ##  [24] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_165211.csv.gz"    
    ##  [25] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_175212.csv.gz"    
    ##  [26] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_185213.csv.gz"    
    ##  [27] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_195214.csv.gz"    
    ##  [28] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_205214.csv.gz"    
    ##  [29] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_215215.csv.gz"    
    ##  [30] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_225215.csv.gz"    
    ##  [31] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_235216.csv.gz"    
    ##  [32] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_005217.csv.gz"    
    ##  [33] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_015219.csv.gz"    
    ##  [34] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_025220.csv.gz"    
    ##  [35] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_035221.csv.gz"    
    ##  [36] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_045222.csv.gz"    
    ##  [37] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_055223.csv.gz"    
    ##  [38] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_065224.csv.gz"    
    ##  [39] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_075225.csv.gz"    
    ##  [40] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_085226.csv.gz"    
    ##  [41] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_095227.csv.gz"    
    ##  [42] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_105229.csv.gz"    
    ##  [43] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_115230.csv.gz"    
    ##  [44] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_125231.csv.gz"    
    ##  [45] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_135232.csv.gz"    
    ##  [46] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_145232.csv.gz"    
    ##  [47] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_155233.csv.gz"    
    ##  [48] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_165234.csv.gz"    
    ##  [49] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_175234.csv.gz"    
    ##  [50] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235 (1).csv.gz"
    ##  [51] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235.csv.gz"    
    ##  [52] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_195236.csv.gz"    
    ##  [53] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_205236.csv.gz"    
    ##  [54] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_215237.csv.gz"    
    ##  [55] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_225238.csv.gz"    
    ##  [56] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_235239.csv.gz"    
    ##  [57] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_005240.csv.gz"    
    ##  [58] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_015241.csv.gz"    
    ##  [59] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_025242.csv.gz"    
    ##  [60] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_035243.csv.gz"    
    ##  [61] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_045244.csv.gz"    
    ##  [62] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_055245.csv.gz"    
    ##  [63] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_065246.csv.gz"    
    ##  [64] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_075248.csv.gz"    
    ##  [65] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_085249.csv.gz"    
    ##  [66] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_095250.csv.gz"    
    ##  [67] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_105251.csv.gz"    
    ##  [68] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_115252.csv.gz"    
    ##  [69] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_125253.csv.gz"    
    ##  [70] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_135254.csv.gz"    
    ##  [71] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_145254.csv.gz"    
    ##  [72] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_155255.csv.gz"    
    ##  [73] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_165256.csv.gz"    
    ##  [74] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_175256.csv.gz"    
    ##  [75] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_185257.csv.gz"    
    ##  [76] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_195258.csv.gz"    
    ##  [77] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_205258.csv.gz"    
    ##  [78] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_215259.csv.gz"    
    ##  [79] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_225300.csv.gz"    
    ##  [80] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_235301.csv.gz"    
    ##  [81] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_005302.csv.gz"    
    ##  [82] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_015303.csv.gz"    
    ##  [83] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_025304.csv.gz"    
    ##  [84] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_035305.csv.gz"    
    ##  [85] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_045306.csv.gz"    
    ##  [86] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_055308.csv.gz"    
    ##  [87] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_065309.csv.gz"    
    ##  [88] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_075310.csv.gz"    
    ##  [89] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_085311.csv.gz"    
    ##  [90] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_095312.csv.gz"    
    ##  [91] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_105313.csv.gz"    
    ##  [92] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_115315.csv.gz"    
    ##  [93] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_125316.csv.gz"    
    ##  [94] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_135316.csv.gz"    
    ##  [95] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_145317.csv.gz"    
    ##  [96] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_155318.csv.gz"    
    ##  [97] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_165318.csv.gz"    
    ##  [98] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_175319.csv.gz"    
    ##  [99] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_185320.csv.gz"    
    ## [100] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_195321.csv.gz"    
    ## [101] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_205321.csv.gz"    
    ## [102] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_215322.csv.gz"    
    ## [103] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_225323.csv.gz"    
    ## [104] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_235323.csv.gz"    
    ## [105] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_005324.csv.gz"    
    ## [106] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_015326.csv.gz"    
    ## [107] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_025327.csv.gz"    
    ## [108] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_035328.csv.gz"    
    ## [109] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_045329.csv.gz"    
    ## [110] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_055330.csv.gz"    
    ## [111] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_065331.csv.gz"    
    ## [112] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_075332.csv.gz"    
    ## [113] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_085334.csv.gz"    
    ## [114] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_095335.csv.gz"    
    ## [115] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_105336.csv.gz"    
    ## [116] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_115337.csv.gz"    
    ## [117] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_125338.csv.gz"    
    ## [118] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_135338.csv.gz"    
    ## [119] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_145339.csv.gz"    
    ## [120] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_155340.csv.gz"    
    ## [121] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_165340.csv.gz"    
    ## [122] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_175341.csv.gz"    
    ## [123] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_185342.csv.gz"    
    ## [124] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_195342.csv.gz"    
    ## [125] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_205343.csv.gz"    
    ## [126] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_215344.csv.gz"    
    ## [127] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_225345.csv.gz"    
    ## [128] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_235346.csv.gz"    
    ## [129] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_005347.csv.gz"    
    ## [130] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_015348.csv.gz"    
    ## [131] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_025349.csv.gz"    
    ## [132] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_035350.csv.gz"    
    ## [133] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_045351.csv.gz"    
    ## [134] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_055352.csv.gz"    
    ## [135] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_065353.csv.gz"    
    ## [136] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_075355.csv.gz"    
    ## [137] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_085356.csv.gz"    
    ## [138] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_095357.csv.gz"    
    ## [139] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_105358.csv.gz"    
    ## [140] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_115359.csv.gz"    
    ## [141] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_125400.csv.gz"    
    ## [142] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_135401.csv.gz"    
    ## [143] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_145402.csv.gz"    
    ## [144] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_155402.csv.gz"    
    ## [145] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_165403.csv.gz"    
    ## [146] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_175404.csv.gz"    
    ## [147] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_185404.csv.gz"    
    ## [148] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_195405.csv.gz"    
    ## [149] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_205406.csv.gz"    
    ## [150] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_215406.csv.gz"    
    ## [1] "beep"
    ## NULL
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_175150.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_185150.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_195151.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_205152.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_215153.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_225153.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-22_235154.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_005155.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_015156.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_025157.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_035158.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_045200.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_055201.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_065202.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_075203.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_085204.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_095205.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_105206.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_115207.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_125209.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_135209.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_145210.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_155211.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_165211.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_175212.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_185213.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_195214.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_205214.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_215215.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_225215.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-23_235216.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_005217.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_015219.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_025220.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_035221.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_045222.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_055223.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_065224.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_075225.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_085226.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_095227.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_105229.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_115230.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_125231.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_135232.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_145232.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_155233.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_165234.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_175234.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235 (1).csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_185235.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_195236.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_205236.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_215237.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_225238.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-24_235239.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_005240.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_015241.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_025242.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_035243.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_045244.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_055245.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_065246.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_075248.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_085249.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_095250.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_105251.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_115252.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_125253.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_135254.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_145254.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_155255.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_165256.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_175256.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_185257.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_195258.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_205258.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_215259.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_225300.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-25_235301.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_005302.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_015303.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_025304.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_035305.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_045306.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_055308.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_065309.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_075310.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_085311.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_095312.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_105313.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_115315.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_125316.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_135316.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_145317.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_155318.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_165318.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_175319.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_185320.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_195321.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_205321.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_215322.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_225323.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-26_235323.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_005324.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_015326.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_025327.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_035328.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_045329.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_055330.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_065331.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_075332.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_085334.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_095335.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_105336.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_115337.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_125338.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_135338.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_145339.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_155340.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_165340.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_175341.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_185342.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_195342.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_205343.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_215344.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_225345.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-27_235346.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_005347.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_015348.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_025349.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_035350.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_045351.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_055352.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_065353.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_075355.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_085356.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_095357.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_105358.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_115359.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_125400.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_135401.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_145402.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_155402.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_165403.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_175404.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_185404.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_195405.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_205406.csv.gz"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-raw-data.2020-09-28_215406.csv.gz"
    ## [1] 2
    ## [1] "preparing 147 node health files for merge"
    ## [1] "node"
    ##   [1] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_175150.csv.gz"
    ##   [2] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_185151.csv.gz"
    ##   [3] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_195152.csv.gz"
    ##   [4] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_205152.csv.gz"
    ##   [5] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_215153.csv.gz"
    ##   [6] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_225154.csv.gz"
    ##   [7] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_235155.csv.gz"
    ##   [8] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_005155.csv.gz"
    ##   [9] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_015157.csv.gz"
    ##  [10] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_025157.csv.gz"
    ##  [11] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_035159.csv.gz"
    ##  [12] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_045200.csv.gz"
    ##  [13] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_055201.csv.gz"
    ##  [14] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_065202.csv.gz"
    ##  [15] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_075203.csv.gz"
    ##  [16] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_085204.csv.gz"
    ##  [17] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_095205.csv.gz"
    ##  [18] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_105207.csv.gz"
    ##  [19] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_115208.csv.gz"
    ##  [20] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_125209.csv.gz"
    ##  [21] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_135210.csv.gz"
    ##  [22] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_145211.csv.gz"
    ##  [23] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_155211.csv.gz"
    ##  [24] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_165212.csv.gz"
    ##  [25] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_175213.csv.gz"
    ##  [26] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_185213.csv.gz"
    ##  [27] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_195214.csv.gz"
    ##  [28] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_215215.csv.gz"
    ##  [29] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_225216.csv.gz"
    ##  [30] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_235217.csv.gz"
    ##  [31] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_005218.csv.gz"
    ##  [32] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_015219.csv.gz"
    ##  [33] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_025220.csv.gz"
    ##  [34] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_035221.csv.gz"
    ##  [35] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_045222.csv.gz"
    ##  [36] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_055223.csv.gz"
    ##  [37] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_065224.csv.gz"
    ##  [38] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_075226.csv.gz"
    ##  [39] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_085227.csv.gz"
    ##  [40] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_095228.csv.gz"
    ##  [41] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_105229.csv.gz"
    ##  [42] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_115230.csv.gz"
    ##  [43] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_125231.csv.gz"
    ##  [44] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_135232.csv.gz"
    ##  [45] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_145233.csv.gz"
    ##  [46] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_155234.csv.gz"
    ##  [47] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_165234.csv.gz"
    ##  [48] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_175235.csv.gz"
    ##  [49] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_185236.csv.gz"
    ##  [50] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_195236.csv.gz"
    ##  [51] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_205237.csv.gz"
    ##  [52] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_215238.csv.gz"
    ##  [53] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_225238.csv.gz"
    ##  [54] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_235239.csv.gz"
    ##  [55] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_005240.csv.gz"
    ##  [56] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_015241.csv.gz"
    ##  [57] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_025242.csv.gz"
    ##  [58] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_035243.csv.gz"
    ##  [59] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_045244.csv.gz"
    ##  [60] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_055245.csv.gz"
    ##  [61] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_065246.csv.gz"
    ##  [62] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_075248.csv.gz"
    ##  [63] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_085249.csv.gz"
    ##  [64] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_095250.csv.gz"
    ##  [65] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_105251.csv.gz"
    ##  [66] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_115252.csv.gz"
    ##  [67] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_135254.csv.gz"
    ##  [68] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_145255.csv.gz"
    ##  [69] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_155255.csv.gz"
    ##  [70] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_165256.csv.gz"
    ##  [71] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_175257.csv.gz"
    ##  [72] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_185258.csv.gz"
    ##  [73] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_195258.csv.gz"
    ##  [74] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_205259.csv.gz"
    ##  [75] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_215300.csv.gz"
    ##  [76] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_225300.csv.gz"
    ##  [77] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_235301.csv.gz"
    ##  [78] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_005302.csv.gz"
    ##  [79] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_015303.csv.gz"
    ##  [80] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_025304.csv.gz"
    ##  [81] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_035305.csv.gz"
    ##  [82] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_045307.csv.gz"
    ##  [83] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_055308.csv.gz"
    ##  [84] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_065309.csv.gz"
    ##  [85] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_075310.csv.gz"
    ##  [86] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_085311.csv.gz"
    ##  [87] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_095312.csv.gz"
    ##  [88] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_105314.csv.gz"
    ##  [89] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_115315.csv.gz"
    ##  [90] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_125316.csv.gz"
    ##  [91] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_135317.csv.gz"
    ##  [92] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_145318.csv.gz"
    ##  [93] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_155318.csv.gz"
    ##  [94] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_165319.csv.gz"
    ##  [95] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_175320.csv.gz"
    ##  [96] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_185321.csv.gz"
    ##  [97] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_195321.csv.gz"
    ##  [98] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_205322.csv.gz"
    ##  [99] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_215322.csv.gz"
    ## [100] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_225323.csv.gz"
    ## [101] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_235324.csv.gz"
    ## [102] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_005325.csv.gz"
    ## [103] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_015326.csv.gz"
    ## [104] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_025327.csv.gz"
    ## [105] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_035328.csv.gz"
    ## [106] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_045329.csv.gz"
    ## [107] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_055330.csv.gz"
    ## [108] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_065331.csv.gz"
    ## [109] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_075333.csv.gz"
    ## [110] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_085334.csv.gz"
    ## [111] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_095335.csv.gz"
    ## [112] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_105336.csv.gz"
    ## [113] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_115337.csv.gz"
    ## [114] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_135339.csv.gz"
    ## [115] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_145340.csv.gz"
    ## [116] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_155340.csv.gz"
    ## [117] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_165341.csv.gz"
    ## [118] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_175342.csv.gz"
    ## [119] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_185342.csv.gz"
    ## [120] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_195343.csv.gz"
    ## [121] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_205344.csv.gz"
    ## [122] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_215344.csv.gz"
    ## [123] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_225345.csv.gz"
    ## [124] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_235346.csv.gz"
    ## [125] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_005347.csv.gz"
    ## [126] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_015348.csv.gz"
    ## [127] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_025349.csv.gz"
    ## [128] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_035350.csv.gz"
    ## [129] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_045351.csv.gz"
    ## [130] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_055352.csv.gz"
    ## [131] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_065354.csv.gz"
    ## [132] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_075355.csv.gz"
    ## [133] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_085356.csv.gz"
    ## [134] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_095357.csv.gz"
    ## [135] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_105358.csv.gz"
    ## [136] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_115359.csv.gz"
    ## [137] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_125401.csv.gz"
    ## [138] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_135401.csv.gz"
    ## [139] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_145402.csv.gz"
    ## [140] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_155403.csv.gz"
    ## [141] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_165404.csv.gz"
    ## [142] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_175404.csv.gz"
    ## [143] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_185405.csv.gz"
    ## [144] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_195406.csv.gz"
    ## [145] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_205406.csv.gz"
    ## [146] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_215407.csv.gz"
    ## [147] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_225407.csv.gz"
    ## [1] "node"
    ## NULL
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_175150.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 158 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_185151.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_195152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 134 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_205152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 113 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_215153.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 100 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_225154.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-22_235155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 183 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_005155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_015157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 239 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_025157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 239 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_035159.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 238 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_045200.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_055201.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_065202.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_075203.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 226 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_085204.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_095205.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_105207.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 237 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_115208.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_125209.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 212 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_135210.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 146 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_145211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 106 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_155211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 100 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_165212.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 108 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_175213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 123 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_185213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 120 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_195214.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 104 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_215215.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 116 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_225216.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 113 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-23_235217.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 161 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_005218.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 244 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_015219.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 233 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_025220.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 225 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_035221.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 234 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_045222.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 230 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_055223.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_065224.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 231 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_075226.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 219 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_085227.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 209 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_095228.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 222 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_105229.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 219 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_115230.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 218 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_125231.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_135232.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 142 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_145233.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 108 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_155234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 124 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_165234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 107 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_175235.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 106 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_185236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 114 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_195236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 110 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_205237.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 104 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_215238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 109 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_225238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 127 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-24_235239.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 179 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_005240.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_015241.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_025242.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_035243.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_045244.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_055245.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 222 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_065246.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_075248.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_085249.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 211 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_095250.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 208 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_105251.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 201 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_115252.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_135254.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 181 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_145255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 134 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_155255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 128 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_165256.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 96 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_175257.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 130 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_185258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 90 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_195258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 94 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_205259.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 94 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_215300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 102 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_225300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 122 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-25_235301.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 195 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_005302.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 205 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_015303.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 198 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_025304.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 198 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_035305.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_045307.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 211 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_055308.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 226 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_065309.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 229 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_075310.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_085311.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 232 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_095312.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_105314.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 236 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_115315.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 228 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_125316.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_135317.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 158 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_145318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 118 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_155318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 103 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_165319.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 119 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_175320.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 95 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_185321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 85 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_195321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 97 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_205322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_215322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 115 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_225323.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 99 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-26_235324.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 151 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_005325.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 231 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_015326.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 252 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_025327.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 213 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_035328.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 218 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_045329.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 226 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_055330.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_065331.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 244 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_075333.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_085334.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_095335.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 225 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_105336.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_115337.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 201 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_135339.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 93 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_145340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 108 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_155340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 88 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_165341.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 81 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_175342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 82 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_185342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 100 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_195343.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 86 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_205344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 105 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_215344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 98 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_225345.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 125 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-27_235346.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 205 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_005347.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 225 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_015348.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 228 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_025349.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_035350.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 227 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_045351.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_055352.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 214 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_065354.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 220 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_075355.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_085356.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 221 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_095357.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 223 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_105358.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_115359.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 217 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_125401.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 215 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_135401.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 178 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_145402.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 87 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_155403.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 114 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_165404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 103 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_175404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 105 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_185405.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 106 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_195406.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 91 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_205406.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 83 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_215407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 161 bad time format records"
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-node-health.2020-09-28_225407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "dropped 173 bad time format records"
    ## [1] "preparing 148 gps files for merge"
    ## [1] "gps"
    ##   [1] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_175150.csv.gz"
    ##   [2] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_185151.csv.gz"
    ##   [3] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_195152.csv.gz"
    ##   [4] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_205152.csv.gz"
    ##   [5] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_215153.csv.gz"
    ##   [6] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_225154.csv.gz"
    ##   [7] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_235155.csv.gz"
    ##   [8] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_005155.csv.gz"
    ##   [9] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_015157.csv.gz"
    ##  [10] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_025157.csv.gz"
    ##  [11] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_035159.csv.gz"
    ##  [12] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_045200.csv.gz"
    ##  [13] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_055201.csv.gz"
    ##  [14] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_065202.csv.gz"
    ##  [15] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_075203.csv.gz"
    ##  [16] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_085204.csv.gz"
    ##  [17] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_095205.csv.gz"
    ##  [18] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_105207.csv.gz"
    ##  [19] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_115208.csv.gz"
    ##  [20] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_125209.csv.gz"
    ##  [21] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_135210.csv.gz"
    ##  [22] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_145211.csv.gz"
    ##  [23] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_155211.csv.gz"
    ##  [24] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_165212.csv.gz"
    ##  [25] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_175213.csv.gz"
    ##  [26] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_185213.csv.gz"
    ##  [27] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_195214.csv.gz"
    ##  [28] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_205215.csv.gz"
    ##  [29] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_215215.csv.gz"
    ##  [30] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_225216.csv.gz"
    ##  [31] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_235217.csv.gz"
    ##  [32] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_005218.csv.gz"
    ##  [33] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_015219.csv.gz"
    ##  [34] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_025220.csv.gz"
    ##  [35] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_035221.csv.gz"
    ##  [36] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_045222.csv.gz"
    ##  [37] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_055223.csv.gz"
    ##  [38] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_065224.csv.gz"
    ##  [39] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_075226.csv.gz"
    ##  [40] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_085226.csv.gz"
    ##  [41] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_095228.csv.gz"
    ##  [42] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_105229.csv.gz"
    ##  [43] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_115230.csv.gz"
    ##  [44] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_125231.csv.gz"
    ##  [45] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_135232.csv.gz"
    ##  [46] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_145233.csv.gz"
    ##  [47] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_155234.csv.gz"
    ##  [48] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_165234.csv.gz"
    ##  [49] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_175235.csv.gz"
    ##  [50] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_185236.csv.gz"
    ##  [51] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_195236.csv.gz"
    ##  [52] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_205237.csv.gz"
    ##  [53] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_215238.csv.gz"
    ##  [54] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_225238.csv.gz"
    ##  [55] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_235239.csv.gz"
    ##  [56] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_005240.csv.gz"
    ##  [57] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_015241.csv.gz"
    ##  [58] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_025242.csv.gz"
    ##  [59] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_035243.csv.gz"
    ##  [60] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_045244.csv.gz"
    ##  [61] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_055245.csv.gz"
    ##  [62] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_065246.csv.gz"
    ##  [63] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_075248.csv.gz"
    ##  [64] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_085249.csv.gz"
    ##  [65] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_095250.csv.gz"
    ##  [66] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_105251.csv.gz"
    ##  [67] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_115252.csv.gz"
    ##  [68] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_125253.csv.gz"
    ##  [69] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_135254.csv.gz"
    ##  [70] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_145255.csv.gz"
    ##  [71] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_155255.csv.gz"
    ##  [72] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_165256.csv.gz"
    ##  [73] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_175257.csv.gz"
    ##  [74] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_185258.csv.gz"
    ##  [75] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_195258.csv.gz"
    ##  [76] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_205259.csv.gz"
    ##  [77] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_215300.csv.gz"
    ##  [78] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_225300.csv.gz"
    ##  [79] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_235301.csv.gz"
    ##  [80] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_005302.csv.gz"
    ##  [81] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_015303.csv.gz"
    ##  [82] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_025304.csv.gz"
    ##  [83] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_035305.csv.gz"
    ##  [84] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_045307.csv.gz"
    ##  [85] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_055308.csv.gz"
    ##  [86] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_065309.csv.gz"
    ##  [87] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_075310.csv.gz"
    ##  [88] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_085311.csv.gz"
    ##  [89] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_095312.csv.gz"
    ##  [90] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_105314.csv.gz"
    ##  [91] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_115315.csv.gz"
    ##  [92] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_125316.csv.gz"
    ##  [93] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_135317.csv.gz"
    ##  [94] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_145318.csv.gz"
    ##  [95] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_155318.csv.gz"
    ##  [96] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_165319.csv.gz"
    ##  [97] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_175320.csv.gz"
    ##  [98] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_185321.csv.gz"
    ##  [99] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_195321.csv.gz"
    ## [100] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_205322.csv.gz"
    ## [101] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_215322.csv.gz"
    ## [102] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_225323.csv.gz"
    ## [103] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_235324.csv.gz"
    ## [104] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_005325.csv.gz"
    ## [105] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_015326.csv.gz"
    ## [106] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_025327.csv.gz"
    ## [107] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_035328.csv.gz"
    ## [108] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_045329.csv.gz"
    ## [109] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_055330.csv.gz"
    ## [110] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_065331.csv.gz"
    ## [111] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_075333.csv.gz"
    ## [112] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_085334.csv.gz"
    ## [113] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_095335.csv.gz"
    ## [114] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_105336.csv.gz"
    ## [115] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_115337.csv.gz"
    ## [116] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_125338.csv.gz"
    ## [117] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_135339.csv.gz"
    ## [118] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_145340.csv.gz"
    ## [119] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_155340.csv.gz"
    ## [120] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_165341.csv.gz"
    ## [121] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_175342.csv.gz"
    ## [122] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_185342.csv.gz"
    ## [123] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_195343.csv.gz"
    ## [124] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_205344.csv.gz"
    ## [125] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_215344.csv.gz"
    ## [126] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_225345.csv.gz"
    ## [127] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_235346.csv.gz"
    ## [128] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_005347.csv.gz"
    ## [129] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_015348.csv.gz"
    ## [130] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_025349.csv.gz"
    ## [131] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_035350.csv.gz"
    ## [132] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_045351.csv.gz"
    ## [133] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_055352.csv.gz"
    ## [134] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_065354.csv.gz"
    ## [135] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_075355.csv.gz"
    ## [136] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_085356.csv.gz"
    ## [137] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_095357.csv.gz"
    ## [138] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_105358.csv.gz"
    ## [139] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_125400.csv.gz"
    ## [140] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_135401.csv.gz"
    ## [141] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_145402.csv.gz"
    ## [142] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_155403.csv.gz"
    ## [143] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_165404.csv.gz"
    ## [144] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_175404.csv.gz"
    ## [145] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_185405.csv.gz"
    ## [146] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_205406.csv.gz"
    ## [147] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_215407.csv.gz"
    ## [148] "../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_225407.csv.gz"
    ## [1] "gps"
    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_175150.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_185151.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_195152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_205152.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_215153.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_225154.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-22_235155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_005155.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_015157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_025157.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_035159.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_045200.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_055201.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_065202.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_075203.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_085204.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_095205.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_105207.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_115208.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_125209.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_135210.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_145211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_155211.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_165212.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_175213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_185213.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_195214.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_205215.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_215215.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_225216.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-23_235217.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_005218.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_015219.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_025220.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_035221.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_045222.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_055223.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_065224.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_075226.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_085226.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_095228.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_105229.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_115230.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_125231.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_135232.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_145233.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_155234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_165234.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_175235.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_185236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_195236.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_205237.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_215238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_225238.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-24_235239.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_005240.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_015241.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_025242.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_035243.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_045244.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_055245.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_065246.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_075248.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_085249.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_095250.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_105251.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_115252.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_125253.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_135254.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_145255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_155255.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_165256.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_175257.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_185258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_195258.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_205259.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_215300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_225300.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-25_235301.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_005302.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_015303.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_025304.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_035305.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_045307.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_055308.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_065309.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_075310.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_085311.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_095312.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_105314.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_115315.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_125316.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_135317.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_145318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_155318.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_165319.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_175320.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_185321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_195321.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_205322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_215322.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_225323.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-26_235324.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_005325.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_015326.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_025327.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_035328.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_045329.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_055330.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_065331.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_075333.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_085334.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_095335.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_105336.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_115337.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_125338.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_135339.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_145340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_155340.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_165341.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_175342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_185342.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_195343.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_205344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_215344.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_225345.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-27_235346.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_005347.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_015348.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_025349.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_035350.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_045351.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_055352.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_065354.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_075355.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_085356.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_095357.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_105358.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_125400.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_135401.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_145402.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_155403.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_165404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_175404.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_185405.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_205406.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_215407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2
    ## [1] "merging file: ../data_tools/datafiles/Sep22-28/CTT-B0ED7D47B60C-gps.2020-09-28_225407.csv.gz"

    ## Warning in read.table(file = file, header = header, sep = sep, quote = quote, :
    ## not all columns named in 'colClasses' exist

    ## [1] 2

``` r
#set arguments if you choose to subset by date or tags
```
