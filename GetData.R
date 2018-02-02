# YouTubeInsights: GetData.R
# This script does the initial extraction of data and saves everything in .csv files
# in the data directory

# Load libraries
library(svMisc)
library(data.table)

# Load configuration
source("Config.R")

# Load helper functions
source("YouTubeAPI.R")

# Create reportname indicating channels and date range
reportname <- NULL
for (i in 1:nrow(channels)) reportname <- paste(reportname, channels[i]$Channelname, sep = if (i == 1) "" else "-")
reportname <- paste(earliestdate,latestdate,reportname, sep = ".")

videos <- data.table(NULL)
videostats <- data.table(NULL)
videoByCountryTotals <- data.table(NULL)
videoByCountryDetails <- data.table(NULL)
captions <- data.table(NULL)
tags <- data.table(NULL)
localizations <- data.table(NULL)
playbacklocations <- data.table(NULL)
trafficsources <- data.table(NULL)

# For all channels
for (channelno in 1:nrow(channels)) {

      # Get channel ID and name for channel
      ChannelID <- as.character(channels[channelno,]$ChannelID)
      Channelname <- as.character(channels[channelno,]$Channelname)
      
      # Authenticate for this channel
      cat("Authenticate access to the", Channelname, "channel in browser\n\n")
      # Request authorization token
      googleAuthR::gar_auth(new_user = TRUE)
      
            
      # Get all public videos, add columns for languages
      channelvideos <- cbind(get.videos(ChannelID), defaultLanguage = NA, defaultAudioLanguage = NA)
      videos <- rbind(videos, channelvideos)
      

      # Get stats for all videos in channel
      for (videono in 1:nrow(channelvideos)) {

            # Display progress bar
            progress(videono, max.value = nrow(channelvideos), progress.bar = FALSE)
            
            # Find video ID for this video
            videoId <- channelvideos[videono,]$snippet.resourceId.videoId
                        
            # Get viewer interaction data (views, likes etc.)
            startdate <- max(earliestdate, format.POSIXct(channelvideos[videono,]$snippet.publishedAt, format = "%Y-%m-%d", usetz = FALSE))
            if (startdate <= latestdate) {
                  # Get video stat totals and by country
                  if ("videostats" %in% datatables) {
                        videostats <- rbind(videostats, get.video.stats(ChannelID, videoId, startdate, latestdate))
                        videoByCountryTotals <- rbind(videoByCountryTotals, get.video.countrytotals(ChannelID, videoId, startdate, latestdate))
                  }

                  # Get video playback locations
                  if ("playbacklocations" %in% datatables) {
                        nextplaybacklocations <- get.video.playbacklocations(ChannelID, videoId, startdate, latestdate)
                        # If results are returned
                        if (nrow(nextplaybacklocations)) {
                              nextplaybacklocations <- cbind(video = videoId, nextplaybacklocations)
                              playbacklocations <- rbind(playbacklocations, nextplaybacklocations)
                        }
                  }
                  
                  # Get video traffic sources
                  if ("trafficsources" %in% datatables) {
                        nexttrafficsources <- get.video.trafficsources(ChannelID, videoId, startdate, latestdate)
                        # If results are returned
                        if (nrow(nexttrafficsources)) {
                              nexttrafficsources <- cbind(video = videoId, nexttrafficsources)
                              trafficsources <- rbind(trafficsources, nexttrafficsources)
                        }
                  }
                  
                  # Get stats by day and country for selected countries
                  if ("videoByCountryDetails" %in% datatables) {
                        for (country in countries) {
                              details <- get.video.countrydetails(ChannelID, videoId, country, startdate, latestdate)
                              # If results are returned
                              if (nrow(details)) {
                                    details <- cbind(video = videoId, country = country, details)
                                    videoByCountryDetails <- rbind(videoByCountryDetails, details)
                              }
                        } # for (country in countries)
                  } # for (country in countries)
            } # if (startdate <= latestdate)

                        
            # Get caption data
            if ("captions" %in% datatables) {
                  nextcaptions <- get.video.captions(videoId)
                  
                  if (length(nextcaptions$snippet)>0) {
                        # Specify columns to return, query might return different number of columns
                        captions <- rbind(captions, nextcaptions$snippet %>% select(videoId, lastUpdated, trackKind,language, name, audioTrackType, isCC, isLarge, isEasyReader, isDraft, isAutoSynced, status))
                  }
                  rm(nextcaptions)      
            } # Get caption data
            


            # Get video information
            nextinfo <- get.video.info(videoId)
            
            if (length(nextinfo$snippet$tags)>0 & "tags" %in% datatables) {
                  # Add tags for this video to tags
                  nexttags <- nextinfo$snippet$tags[[1]]
                  tags <- rbind(tags, data.frame( videoId = rep(videoId, length(nexttags)), tag = nexttags)  )
            }
            
            # Get localization data
            if (length(nextinfo$localizations)>0 & "localizations" %in% datatables) {
            # Get localized language codes
                  languages <- colnames(nextinfo$localizations)
            
            # Add all localizations
                  for (localizationindex in 1:length(languages)) {
                        localizations <- rbind(localizations, data.frame( videoId = videoId, language = languages[localizationindex], title = nextinfo$localizations[1,localizationindex]$title, description = nextinfo$localizations[1,localizationindex]$description ))
                  }
            } # Get localization data
            
            # Add language information if set on video
            if (!is.null(nextinfo$snippet$defaultLanguage)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$defaultLanguage <- nextinfo$snippet$defaultLanguage
            }
            
            if (!is.null(nextinfo$snippet$defaultAudioLanguage)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$defaultAudioLanguage <- nextinfo$snippet$defaultAudioLanguage
            }
            
            
      } # For all videos in channel

} # For all channels


# Delete authentication token
unlink(".httr-oauth")

# Save data frames to disk
for (datatable in datatables) {
      write.csv(get(datatable), file = paste(datadir, datatable, ".", reportname, ".csv", sep = ""))
}

