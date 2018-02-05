# Create new data tables suitable for analysis

# Load libraries
library(data.table)
library(dplyr)
library(lubridate)

# Load configuration
source("Config.R")

# Load data
load(paste(datadir, rawfile, sep = ""))

# Initialize list of data tables to include in processed data
processedtables <- append(datatables, "channels")
processedtables <- append(processedtables, "minuteValue")
processedtables <- append(processedtables, "maximumSlope")
processedtables <- append(processedtables, "constantTrafficDuration")
processedtables <- append(processedtables, "minimumObservations")



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


# Views and minutes by video and age of video
VIDEOxAGE <- merge(videostats, videos, by = "videoId") %>%
      subset(select = c(videoId, day, publishedAt,views, estimatedMinutesWatched, averageViewPercentage, channelTitle))
# Calculate age in days
VIDEOxAGE$age <- as_date(VIDEOxAGE$day) - as.Date(VIDEOxAGE$publishedAt)
processedtables <- append(processedtables, "VIDEOxAGE")


# Estimate value of videos
VIDEOxVALUE <- videos %>% subset(select = -c(position))
VIDEOxVALUE$intercept <- as.numeric(NA)
VIDEOxVALUE$slope <- as.numeric(NA)
VIDEOxVALUE$value <- as.numeric(NA)

# For all videos
for (i in 1:nrow(VIDEOxVALUE)) {
      nextvideoId <- as.character(VIDEOxVALUE[i,]$videoId)
      videoTraffic <- VIDEOxAGE[which(videoId == nextvideoId)]

      # Calculate value if enough observations
      if (nrow(videoTraffic) >= minimumObservations) {
            model = lm(estimatedMinutesWatched ~ age, data = videoTraffic)
            intercept <- model$coefficients[1]
            slope <- model$coefficients[2]

            # Use area under traffic curve if slope is below limit
            if (slope < maximumSlope) {
                  VIDEOxVALUE[i,]$value <-  round(- minuteValue * (intercept^2) / (2*slope))
            }
            # Slope is above limit, use constant traffic model
            else {
                  VIDEOxVALUE[i,]$value <-  round(minuteValue * intercept * constantTrafficDuration)
            }
            VIDEOxVALUE[i,]$intercept <- intercept
            VIDEOxVALUE[i,]$slope <- slope
      }
      
            
} # For all videos

processedtables <- append(processedtables, "VIDEOxVALUE")


# Save all tables
save(list = processedtables, file = paste(datadir, processedfile, sep = ""))
