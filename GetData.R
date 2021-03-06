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
for (i in 1:nrow(extractChannels)) reportname <- paste(reportname, extractChannels[i]$channelName, sep = if (i == 1) "" else "-")
reportname <- paste(earliestdate,latestdate,reportname, sep = ".")

videos                  <- data.table(NULL)
videostats              <- data.table(NULL)
videoByCountryTotals    <- data.table(NULL)
videoByCountryDetails   <- data.table(NULL)
captions                <- data.table(NULL)
tags                    <- data.table(NULL)
localizations           <- data.table(NULL)
playbacklocations       <- data.table(NULL)
trafficsources          <- data.table(NULL)
subscribers             <- data.table(NULL)

# For all channels
for (channelno in 1:nrow(extractChannels)) {

      # Get channel ID and name for channel
      channelId <- as.character(extractChannels[channelno,]$channelId)
      channelName <- as.character(extractChannels[channelno,]$channelName)
      
      # Authenticate for this channel
      cat("Authenticate access to the", channelName, "channel in browser\n\n")
      # Request authorization token
      googleAuthR::gar_auth(new_user = TRUE)
      
            
      # Get all public videos, add detail columns
      channelvideos <- cbind(get.videos(channelId),
                             defaultLanguage = as.character(NA),
                             defaultAudioLanguage = as.character(NA),
                             thumbnail = as.character(NA),
                             duration = as.character(NA),
                             dimension = as.character(NA),
                             definition = as.character(NA),
                             caption = as.character(NA),
                             projection = as.character(NA),
                             hasCustomThumbnail = as.logical(NA))
      
      channelvideos$defaultLanguage <- as.character(channelvideos$defaultLanguage)
      channelvideos$defaultAudioLanguage <- as.character(channelvideos$defaultAudioLanguage)
      videos <- rbind(videos, channelvideos)

      # Initialize variable to hold date for earliest published video
      firstvideodate <- latestdate

      # Get stats for all videos in channel
      for (videono in 1:nrow(channelvideos)) {

            # Display progress bar
            progress(videono, max.value = nrow(channelvideos), progress.bar = FALSE)
            
            # Find video ID for this video
            videoId <- channelvideos[videono,]$snippet.resourceId.videoId
                        
            # Get viewer interaction data (views, likes etc.)
            startdate <- max(earliestdate, format.POSIXct(channelvideos[videono,]$snippet.publishedAt, format = "%Y-%m-%d", usetz = FALSE))
            
            # Update firstvideodate if this video has earlier startdate
            if (startdate < firstvideodate) {
                  firstvideodate <- startdate
            }
            if (startdate <= latestdate) {
                  # Get video stat totals and by country
                  if ("videostats" %in% datatables) {
                        videostats <- rbind(videostats, get.video.stats(channelId, videoId, startdate, latestdate))
                        videoByCountryTotals <- rbind(videoByCountryTotals, get.video.countrytotals(channelId, videoId, startdate, latestdate))
                  }

                  # Get video playback locations
                  if ("playbacklocations" %in% datatables) {
                        nextplaybacklocations <- get.video.playbacklocations(channelId, videoId, startdate, latestdate)
                        # If results are returned
                        if (nrow(nextplaybacklocations)) {
                              nextplaybacklocations <- cbind(video = videoId, nextplaybacklocations)
                              playbacklocations <- rbind(playbacklocations, nextplaybacklocations)
                        }
                  }
                  
                  # Get video traffic sources
                  if ("trafficsources" %in% datatables) {
                        nexttrafficsources <- get.video.trafficsources(channelId, videoId, startdate, latestdate)
                        # If results are returned
                        if (nrow(nexttrafficsources)) {
                              nexttrafficsources <- cbind(video = videoId, nexttrafficsources)
                              trafficsources <- rbind(trafficsources, nexttrafficsources)
                        }
                  }
                  
                  # Get stats by day and country for selected countries
                  if ("videoByCountryDetails" %in% datatables) {
                        for (country in countries) {
                              details <- get.video.countrydetails(channelId, videoId, country, startdate, latestdate)
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

            # Add content details
            if (!is.null(nextinfo$contentDetails$duration)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$duration <- nextinfo$contentDetails$duration
            }
            
            if (!is.null(nextinfo$contentDetails$dimension)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$dimension <- nextinfo$contentDetails$dimension
            }
            
            if (!is.null(nextinfo$contentDetails$definition)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$definition <- nextinfo$contentDetails$definition
            }
            
            if (!is.null(nextinfo$contentDetails$caption)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$caption <- nextinfo$contentDetails$caption
            }
            
            if (!is.null(nextinfo$contentDetails$projection)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$projection <- nextinfo$contentDetails$projection
            }
            
            if (!is.null(nextinfo$contentDetails$hasCustomThumbnail)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$hasCustomThumbnail <- nextinfo$contentDetails$hasCustomThumbnail
            }
            
            if (!is.null(nextinfo$snippet$thumbnails$maxres$url)) {
                  videos[which(videos$snippet.resourceId.videoId == videoId),]$thumbnail <- nextinfo$snippet$thumbnails$maxres$url
            }
            
      } # For all videos in channel

      
      # Get channel subscribers
      if ("subscribers" %in% datatables) {
            nextsubscribers <- get.channel.subscribers(channelId, firstvideodate, latestdate)
            # If results are returned
            if (nrow(nextsubscribers)) {
                  nextsubscribers <- cbind(channelId = channelId, nextsubscribers)
                  subscribers <- rbind(subscribers, nextsubscribers)
            }
      }
      
} # For all channels


# Delete authentication token
unlink(".httr-oauth")

# Save data tables to disk
for (datatable in datatables) {
      write.csv(get(datatable), file = paste(datadir, datatable, ".", reportname, ".csv", sep = ""))
}

