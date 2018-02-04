# Create new data tables suitable for analysis

# Load libraries
library(data.table)
library(dplyr)
library(ggplot2)

# Load data
load("YouTube.RData")

# views and minutes by channel and day
CHANNELxDAY <- merge(videos, videostats, by = "videoId") %>%
      merge(channels, by = "channelId") %>%
      as.data.table() %>%
      group_by(channelName, day) %>%
      summarise(views = sum(views), minutes = sum(estimatedMinutesWatched))



# Move to presentation

ggplot(CHANNELxDAY, aes(x = day, y = views, color = channelName)) + geom_line()

