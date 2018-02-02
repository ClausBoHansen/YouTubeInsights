# YouTubeInsights: MergeData.R
# This script read the .csv files, combines the data into data frames and
# do type conversions.

# Load libraries
library(data.table)
library(dplyr)

source("Config.R")

# For all datatables
for (datatable in datatables) {
      assign(datatable, data.table(NULL))
      inputfiles <- list.files(datadir, pattern = paste("^",datatable, "\\..*\\.csv$", sep = ""))
      
      # For all input files
      for (inputfile in inputfiles) {
            filename <- paste(datadir, inputfile, sep = "")
            if (file.size(filename) > 5) {
                  nextpart <- read.csv(filename)
            assign(datatable, rbind(get(datatable), nextpart))
                  
            }
      }
      
      # Remove X columns introduced by write.csv
      assign(datatable, select(get(datatable), -X))
}

# Delete temporary objects
rm(nextpart)
rm(datadir)
rm(datatable)
rm(datatables)
rm(inputfile)
rm(inputfiles)
rm(filename)

