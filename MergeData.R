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


# Set data types

# captions
if ("captions" %in% datatables) {
      captions$lastUpdated <- as.POSIXct(captions$lastUpdated, format = "%Y-%m-%dT%H:%M:%S")
}

# localizations
if ("localizations" %in% datatables) {
      localizations$title <- as.character(localizations$title)
      localizations$description <- as.character(localizations$description)
      # UTF-8
}

# playbacklocations
if ("playbacklocations" %in% datatables) {
}

# tags
if ("tags" %in% datatables) {
}

# trafficsources
if ("trafficsources" %in% datatables) {
}

# videoByCountryDetails
if ("videoByCountryDetails" %in% datatables) {
}

# videoByCountryTotals
if ("videoByCountryTotals" %in% datatables) {
}

# videos
if ("videos" %in% datatables) {
}

# videostats
if ("videostats" %in% datatables) {
}


# Delete temporary objects
rm(nextpart)
rm(datadir)
rm(datatable)
rm(datatables)
rm(inputfile)
rm(inputfiles)
rm(filename)
rm(countries)
rm(earliestdate)
rm(google.client.id)
rm(google.client.secret)
rm(latestdate)
