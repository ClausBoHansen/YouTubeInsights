# Create new data tables suitable for analysis

# Load libraries
library(data.table)
library(dplyr)

# Load configuration
source("Config.R")

# Load data
load(paste(datadir, rawfile, sep = ""))

# Initialize list of data tables to include in processed data
processedtables <- append(datatables, "channels")

# views and watch time by channel and day
CHANNELxDAY <- merge(videos, videostats, by = "videoId") %>%
      merge(channels, by = "channelId") %>%
      as.data.table() %>%
      group_by(channelName, day) %>%
      summarise(views = sum(views), minutes = sum(estimatedMinutesWatched), subscribersChange = sum(subscribersGained) - sum(subscribersLost))

processedtables <- append(processedtables, "CHANNELxDAY")


# Calculate subscribers
SUBSCRIBERSxDAY <- merge(channels, subscribers, by = "channelId") %>% as.data.table()
SUBSCRIBERSxDAY <- SUBSCRIBERSxDAY[order(channelName, day)]
SUBSCRIBERSxDAY$subscribersChange <- SUBSCRIBERSxDAY$subscribersGained - SUBSCRIBERSxDAY$subscribersLost

SUBSCRIBERSxDAY$subscribers <- 0
previouschannel <- ""
previoussum <- 0
for (i in 1:nrow(SUBSCRIBERSxDAY)) {
      if (SUBSCRIBERSxDAY[i, "channelName"] != previouschannel) {
            previoussum <- 0
      }
      newsum <- SUBSCRIBERSxDAY[i, "subscribersChange"] + previoussum
      SUBSCRIBERSxDAY[i, "subscribers"] <- newsum
      previoussum <- newsum
      previouschannel <- SUBSCRIBERSxDAY[i, "channelName"]
}

processedtables <- append(processedtables, "SUBSCRIBERSxDAY")


# Save all tables
save(list = processedtables, file = paste(datadir, processedfile, sep = ""))
