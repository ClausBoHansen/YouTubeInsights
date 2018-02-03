# Create new data tables suitable for analysis

# Load libraries
library(data.table)
library(dplyr)

# views and minutes by channel and day
CHANNELxDAY <- as.data.table(merge(x = videos, y = videostats, by = "videoId")) %>%
      group_by(channelTitle, day) %>%
      summarise(views = sum(views), minutes = sum(estimatedMinutesWatched))

