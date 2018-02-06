# Estimate value of video

# Load libraries
library(data.table)
library(lubridate)

source("Config.R")

get.video.value <- function(estimateForVideoId, estimationdate = now(), minobs = minimumObservations) {

      videoTraffic <- VIDEOxAGE[which(videoId == estimateForVideoId & day < estimationdate)]
      observations <- nrow(videoTraffic)
      
      # If there are sufficient observations to estimate value
      if (observations >= minobs) {
            pastMinutes <- sum(videoTraffic$estimatedMinutesWatched)
            videoTraffic
            
            # Get subset of traffic to estimate future traffic
            estimationTraffic <- videoTraffic[(observations - minobs):observations,]
            estimationTraffic

            # Fit linear regression model to estimationTraffic            
            model = lm(estimatedMinutesWatched ~ age, data = estimationTraffic)
            intercept <- model$coefficients[1]
            slope <- model$coefficients[2]
            
            # Use area under traffic curve if slope is below limit
            if (slope < maximumSlope) {
                  futureMinutes <-  - (intercept^2) / (2*slope)
            }
            # Slope is above limit, use constant traffic model
            else {
                  futureMinutes <-  mean(estimationTraffic$estimatedMinutesWatch) * constantTrafficDuration
            }
            
            estimatedValue <- as.numeric((pastMinutes + futureMinutes) * minuteValue)
            estimatedValue
            
      }
      # If there are not enough observations to estimate value
      else {
            as.numeric(NA)
      }

}
