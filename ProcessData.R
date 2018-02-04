# Create new data tables suitable for analysis

# Load libraries
library(data.table)
library(dplyr)
library(ggplot2)

# Load configuration
source("Config.R")

# Load data
load(paste(datadir, datafile, sep = ""))

# views and watch time by channel and day
CHANNELxDAY <- merge(videos, videostats, by = "videoId") %>%
      merge(channels, by = "channelId") %>%
      as.data.table() %>%
      group_by(channelName, day) %>%
      summarise(views = sum(views), minutes = sum(estimatedMinutesWatched), subscribersChange = sum(subscribersGained) - sum(subscribersLost))

# Calculate subscribers
CHANNELxDAY$subscribers <- 0
previouschannel <- ""
previoussum <- 0
for (i in 1:nrow(CHANNELxDAY)) {
      if (CHANNELxDAY[i, "channelName"] != previouschannel) {
            previoussum <- 0
      }
      newsum <- CHANNELxDAY[i, "subscribersChange"] + previoussum
      CHANNELxDAY[i, "subscribers"] <- newsum
      previoussum <- newsum
      previouschannel <- CHANNELxDAY[i, "channelName"]
}


# Move to presentation

ggplot(CHANNELxDAY, aes(x = day, y = views/1000)) +
      geom_line() +
      facet_wrap(~ channelName, ncol = 3) +
      ggtitle("Views by channel") +
      labs(x = "Date", y = "Views per day [thousands]")

ggplot(CHANNELxDAYxWATCHTIME, aes(x = day, y = minutes/60)) +
      geom_line() +
      facet_wrap(~ channelName, ncol = 3) +
      ggtitle("Watch time by channel") +
      labs(x = "Date", y = "Watch time per day [hours]")

