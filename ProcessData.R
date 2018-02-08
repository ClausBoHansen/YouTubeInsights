# Create new data tables suitable for analysis

# Load libraries
library(data.table)
library(dplyr)
library(lubridate)

# Load configuration
source("Config.R")
source("VideoValue.R")

# Load data
load(paste(datadir, rawfile, sep = ""))

# Initialize list of data tables to include in processed data
processedtables <- append(datatables, "channels")
processedtables <- append(processedtables, "minuteValue")

########################################################################
# views and watch time by channel and day
CHANNELxDAY <- merge(videos, videostats, by = "videoId") %>%
      merge(channels, by = "channelId") %>%
      as.data.table() %>%
      group_by(channelName, day) %>%
      summarise(views = sum(views), minutes = sum(estimatedMinutesWatched), subscribersChange = sum(subscribersGained) - sum(subscribersLost))

processedtables <- append(processedtables, "CHANNELxDAY")


########################################################################
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


########################################################################
# Views and minutes by video and age of video
VIDEOxAGE <- merge(videostats, videos, by = "videoId") %>%
      subset(select = c(videoId, day, publishedAt,views, estimatedMinutesWatched, averageViewPercentage, channelTitle))
# Calculate age in days
VIDEOxAGE$age <- as_date(VIDEOxAGE$day) - as.Date(VIDEOxAGE$publishedAt)

processedtables <- append(processedtables, "VIDEOxAGE")


########################################################################
# Estimate value of videos
VIDEOxVALUE <- videos %>% subset(select = -c(position))
VIDEOxVALUE$value <- as.numeric(NA)

# For all videos
for (i in 1:nrow(VIDEOxVALUE)) {
      nextvideoId <- as.character(VIDEOxVALUE[i,]$videoId)
      VIDEOxVALUE[i,]$value <- get.video.value(nextvideoId)$estvalue

} # For all videos

processedtables <- append(processedtables, "VIDEOxVALUE")


########################################################################
# Calculate value of past traffic by source and channel
SOURCExCHANNEL <- merge(trafficsources, videos, by.x = "video", by.y = "videoId") %>%
      merge(channels, by = "channelId") %>%
      subset(select = c(day, insightTrafficSourceType, estimatedMinutesWatched, channelName)) %>%
      group_by(channelName,insightTrafficSourceType, day) %>%
      summarise(estimatedMinutesWatched = sum(estimatedMinutesWatched)) %>%
      filter(estimatedMinutesWatched > 0)
      
processedtables <- append(processedtables, "SOURCExCHANNEL")


########################################################################
# Save all tables
save(list = processedtables, file = paste(datadir, processedfile, sep = ""))
