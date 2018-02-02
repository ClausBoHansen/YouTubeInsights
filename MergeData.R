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
      localizations$title <- iconv(as.character(localizations$title), from = "UTF-8")
      localizations$description <- iconv(as.character(localizations$description), from = "UTF-8")
}

# playbacklocations
if ("playbacklocations" %in% datatables) {
      playbacklocations$day <- as.POSIXct(playbacklocations$day, format = "%Y-%m-%d")
}

# tags
if ("tags" %in% datatables) {
      tags$tag <- iconv(as.character(tags$tag), from = "UTF-8")
}

# trafficsources
if ("trafficsources" %in% datatables) {
      trafficsources$day <- as.POSIXct(trafficsources$day, format = "%Y-%m-%d")
}

# videoByCountryDetails
if ("videoByCountryDetails" %in% datatables) {
      videoByCountryDetails$day <- as.POSIXct(videoByCountryDetails$day, format = "%Y-%m-%d")
}

# videos
if ("videos" %in% datatables) {
      videos$snippet.publishedAt <- as.POSIXct(videos$snippet.publishedAt, format = "%Y-%m-%d %H:%M:%S")
      videos$snippet.title <- iconv(as.character(videos$snippet.title), from = "UTF-8")
      videos$snippet.description <- iconv(as.character(videos$snippet.description), from = "UTF-8")
}

# videostats
if ("videostats" %in% datatables) {
      videostats$day <- as.POSIXct(videostats$day, format = "%Y-%m-%d")
}

# Save all tables
save(list = datatables, file = "YouTube.RData")

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
