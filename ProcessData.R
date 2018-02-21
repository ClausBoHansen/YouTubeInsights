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
# Views and minutes by country
COUNTRYxCHANNEL <- merge(videoByCountryDetails, videos, by.x = "video", by.y = "videoId") %>%
      merge(channels, by = "channelId") %>%
      subset(select = c(country, day, views, estimatedMinutesWatched, channelName)) %>%
      group_by(channelName,country, day) %>%
      summarise(estimatedMinutesWatched = sum(estimatedMinutesWatched), views = sum(views)) %>%
      filter(estimatedMinutesWatched > 0 & views > 0)

processedtables <- append(processedtables, "COUNTRYxCHANNEL")


########################################################################
# Internet users by country
# If an API or downloadable file is found, this should be moved to GetData.R

# Source: http://www.internetworldstats.com/stats4.htm
INTERNETUSERSxCOUNTRY <- data.table(NULL)

INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "AR", internetUsers = 34785206))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "AT", internetUsers = 7273168))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "AU", internetUsers = 21743803))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "BE", internetUsers = 10060745))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "BR", internetUsers = 139111185))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "CA", internetUsers = 33000381))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "CH", internetUsers = 7558796))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "CL", internetUsers = 14108392))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "CZ", internetUsers = 9323428))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "DE", internetUsers = 72290285))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "DK", internetUsers = 5534770))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "ES", internetUsers = 40148353))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "FI", internetUsers = 5125678))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "FR", internetUsers = 56367330))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "GB", internetUsers = 62091419))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "HR", internetUsers = 3133485))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "IE", internetUsers = 4453436))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "IT", internetUsers = 51836798))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "MX", internetUsers = 69000000))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "NL", internetUsers = 16143879))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "NO", internetUsers = 5311892))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "NZ", internetUsers = 4084520))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "PL", internetUsers = 28267099))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "PT", internetUsers = 7430762))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "SE", internetUsers = 9216226))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "SI", internetUsers = 1563795))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "SK", internetUsers = 4629641))
INTERNETUSERSxCOUNTRY <- rbind(INTERNETUSERSxCOUNTRY, list(country = "US", internetUsers = 286942362))

processedtables <- append(processedtables, "INTERNETUSERSxCOUNTRY")


########################################################################
# Captions by video and country
VIDEOxCAPTION <- merge(videoByCountryTotals, countryLanguages, by = "country") %>%
      merge(captions, by.x = c("video", "language"), by.y = c("videoId", "language"), all.x = TRUE) %>%
      subset(select = c(video, language, country, views, estimatedMinutesWatched, averageViewPercentage, trackKind, status))

VIDEOxCAPTION[which(status == "serving")]$status <- "caption"
VIDEOxCAPTION[which(is.na(status))]$status <- "no caption"

processedtables <- append(processedtables, "VIDEOxCAPTION")



########################################################################
# Save all tables
save(list = processedtables, file = paste(datadir, processedfile, sep = ""))


