# Functions for YouTube statistics

# Load the necessary packages
library(googleAuthR)
library(httpuv)
library(jsonlite)
library(dplyr)


# Set options for Google API access
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/youtube",
                                        "https://www.googleapis.com/auth/youtube.readonly",
                                        "https://www.googleapis.com/auth/youtubepartner",
                                        "https://www.googleapis.com/auth/yt-analytics-monetary.readonly",
                                        "https://www.googleapis.com/auth/youtube.force-ssl",
                                        "https://www.googleapis.com/auth/yt-analytics.readonly"),
        googleAuthR.client_id = google.client.id,
        googleAuthR.client_secret = google.client.secret,
        googleAuthR.rawResponse = TRUE)


get.videos <- function(Channel_ID) {

      # Find uploads playlist ID
      videoargs <- list(part = "contentDetails", id = Channel_ID)
      API <- gar_api_generator("https://www.googleapis.com/youtube/v3/channels",
                               "GET",
                               pars_args = list(part = "", id = ""),
                               data_parse_function = function(x) {
                                     return(fromJSON(rawToChar(x))$items$contentDetails$relatedPlaylists$uploads)
                               }
      )
      uploadsPlaylistId <- API(pars_arguments = videoargs)

      # Find all videos on uploads playlist
      # Only public videos are returned
      fieldslist <- "items(snippet(channelId,channelTitle,description,position,publishedAt,resourceId/videoId,title)),nextPageToken"
      videoargs <- list(part = "snippet", maxResults = 50, playlistId = uploadsPlaylistId, fields = fieldslist)
      API <- gar_api_generator("https://www.googleapis.com/youtube/v3/playlistItems",
                               "GET",
                               pars_args = list(part = "", maxResults = "", pageToken = "", playlistId = "", fields = ""),
                               data_parse_function = function(x) {
                                     return(fromJSON(rawToChar(x)))
                               }
      )
      videosJSON <- API(pars_arguments = videoargs)
      videos <- flatten(videosJSON$items)
#print(names(videos))
      
      # If result is paginated, load rest of pages
      while (!is.null(videosJSON$nextPageToken)) {
            videoargs <- list(part = "snippet", maxResults = 50, pageToken = videosJSON$nextPageToken, playlistId = uploadsPlaylistId, fields = fieldslist)
            videosJSON <- API(pars_arguments = videoargs)
            nextvideos <- flatten(videosJSON$items)
#print(names(nextvideos))
            videos <- rbind(videos, nextvideos)
      }
      videos$snippet.publishedAt <- as.POSIXct(videos$snippet.publishedAt, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
      videos
}


# Get stats for a specific video
get.video.stats <- function(channelID, videoID, startdate, enddate) {
      
      videoargs <- list(ids = paste("channel==", channelID, sep = ""),
                        `start-date` = startdate,
                        `end-date` = enddate,
                        metrics = "views,likes,dislikes,averageViewDuration,estimatedMinutesWatched,shares,subscribersGained,subscribersLost,averageViewPercentage,videosAddedToPlaylists,videosRemovedFromPlaylists",
                        dimensions = "video,day",
                        filters = paste("video==", videoID, sep = ""),
                        alt = "csv")
      
      API <- gar_api_generator("https://www.googleapis.com/youtube/analytics/v1/reports",
                               "GET",
                               pars_args = list(ids = "", `start-date` = "", `end-date` = "", metrics = "", dimensions = "", filters = "", alt = ""),
                               data_parse_function = function(x) {
                                     return(read.csv(text = rawToChar(x)))
                               }
      )
      
      API(pars_arguments = videoargs)
}

# Get stats for a specific video
get.video.countrytotals <- function(channelID, videoID, startdate, enddate) {
      
      videoargs <- list(ids = paste("channel==", channelID, sep = ""),
                        `start-date` = startdate,
                        `end-date` = enddate,
                        metrics = "views,likes,dislikes,averageViewDuration,estimatedMinutesWatched,shares,subscribersGained,subscribersLost,averageViewPercentage,videosAddedToPlaylists,videosRemovedFromPlaylists",
                        dimensions = "video,country",
                        filters = paste("video==", videoID, sep = ""),
                        alt = "csv")
      
      API <- gar_api_generator("https://www.googleapis.com/youtube/analytics/v1/reports",
                               "GET",
                               pars_args = list(ids = "", `start-date` = "", `end-date` = "", metrics = "", dimensions = "", filters = "", alt = ""),
                               data_parse_function = function(x) {
                                     return(read.csv(text = rawToChar(x)))
                               }
      )
      
      API(pars_arguments = videoargs)
}

# Get stats by day for a specific video in specific country
get.video.countrydetails <- function(channelID, videoID, country, startdate, enddate) {
      
      videoargs <- list(ids = paste("channel==", channelID, sep = ""),
                        `start-date` = startdate,
                        `end-date` = enddate,
                        metrics = "views,likes,dislikes,averageViewDuration,estimatedMinutesWatched,shares,subscribersGained,subscribersLost,averageViewPercentage,videosAddedToPlaylists,videosRemovedFromPlaylists",
                        dimensions = "day",
                        filters = paste("video==", videoID,";country==",country, sep = ""),
                        alt = "csv")
      
      API <- gar_api_generator("https://www.googleapis.com/youtube/analytics/v1/reports",
                               "GET",
                               pars_args = list(ids = "", `start-date` = "", `end-date` = "", metrics = "", dimensions = "", filters = "", alt = ""),
                               data_parse_function = function(x) {
                                     return(read.csv(text = rawToChar(x)))
                               }
      )
      
      API(pars_arguments = videoargs)
}


# Get playback locations for a specific video
get.video.playbacklocations <- function(channelID, videoID, startdate, enddate) {
      
      videoargs <- list(ids = paste("channel==", channelID, sep = ""),
                        `start-date` = startdate,
                        `end-date` = enddate,
                        metrics = "views,estimatedMinutesWatched",
                        dimensions = "day,insightPlaybackLocationType",
                        filters = paste("video==", videoID, sep = ""),
                        alt = "csv")
      
      API <- gar_api_generator("https://www.googleapis.com/youtube/analytics/v1/reports",
                               "GET",
                               pars_args = list(ids = "", `start-date` = "", `end-date` = "", metrics = "", dimensions = "", filters = "", alt = ""),
                               data_parse_function = function(x) {
                                     return(read.csv(text = rawToChar(x)))
                               }
      )
      
      API(pars_arguments = videoargs)
}

# Get traffic sources for a specific video
get.video.trafficsources <- function(channelID, videoID, startdate, enddate) {
      
      videoargs <- list(ids = paste("channel==", channelID, sep = ""),
                        `start-date` = startdate,
                        `end-date` = enddate,
                        metrics = "views,estimatedMinutesWatched",
                        dimensions = "day,insightTrafficSourceType",
                        filters = paste("video==", videoID, sep = ""),
                        alt = "csv")
      
      API <- gar_api_generator("https://www.googleapis.com/youtube/analytics/v1/reports",
                               "GET",
                               pars_args = list(ids = "", `start-date` = "", `end-date` = "", metrics = "", dimensions = "", filters = "", alt = ""),
                               data_parse_function = function(x) {
                                     return(read.csv(text = rawToChar(x)))
                               }
      )
      
      API(pars_arguments = videoargs)
}

# Get subscribers gained and lost for specific channel
get.channel.subscribers <- function(channelID, startdate, enddate) {
      
      videoargs <- list(ids = paste("channel==", channelID, sep = ""),
                        `start-date` = startdate,
                        `end-date` = enddate,
                        metrics = "subscribersGained,subscribersLost",
                        dimensions = "day",
                        alt = "csv")
      
      API <- gar_api_generator("https://www.googleapis.com/youtube/analytics/v1/reports",
                               "GET",
                               pars_args = list(ids = "", `start-date` = "", `end-date` = "", metrics = "", dimensions = "", alt = ""),
                               data_parse_function = function(x) {
                                     return(read.csv(text = rawToChar(x)))
                               }
      )
      
      API(pars_arguments = videoargs)
}


# Get captions for a specific video
get.video.captions <- function(videoID) {

      # Find uploads playlist ID
      videoargs <- list(part = "snippet", videoId = videoID)
      API <- gar_api_generator("https://www.googleapis.com/youtube/v3/captions",
                               "GET",
                               pars_args = list(part = "", videoId = ""),
                               data_parse_function = function(x) {
                                     fromJSON(rawToChar(x))$items
                               }
      )
      
      API(pars_arguments = videoargs)
}


# Get information for a specific video
get.video.info <- function(videoID) {
      
      # Find uploads playlist ID
      videoargs <- list(part = "snippet,localizations", id = videoID)
      API <- gar_api_generator("https://www.googleapis.com/youtube/v3/videos",
                               "GET",
                               pars_args = list(part = "", id = ""),
                               data_parse_function = function(x) {
                                     fromJSON(rawToChar(x))$items
                               }
      )
      
      API(pars_arguments = videoargs)
}

