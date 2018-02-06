# Estimate value of video

# Load libraries
library(data.table)
library(lubridate)

source("Config.R")

get.video.value <- function(estimateForVideoId, estimationdate = latestdate, minobs = minimumObservations) {

      videoTraffic <- VIDEOxAGE[which(videoId == estimateForVideoId & day < estimationdate)]
      observations <- nrow(videoTraffic)
      
      pastMinutes <- as.numeric(NULL)
      futureMinutes <- as.numeric(NULL)
#      m <- NULL
      slope <- NULL
      intercept <- NULL
      estimationAverage <- NULL
      
      # If there are sufficient observations to estimate value
      if (observations >= minobs) {
            pastMinutes <- sum(videoTraffic$estimatedMinutesWatched)

            # Get subset of traffic to estimate future traffic
            estimationTraffic <- videoTraffic[(observations - minobs):observations,]

            latestObservation <- max(estimationTraffic$day)
            daysSinceLastObservation <- as.integer(date(estimationdate) - date(latestObservation))

            # If there is data to calculate futureMinutes
            if (daysSinceLastObservation <= maxDaysSinceObservation) {
                  
                  # Fit linear regression model to estimationTraffic            
                  model = lm(estimatedMinutesWatched ~ age, data = estimationTraffic)
#                  model = lm(estimatedMinutesWatched ~ age, data = videoTraffic)
                  intercept <- model$coefficients[1]
                  slope <- model$coefficients[2]
                  estimationAverage <- mean(estimationTraffic$estimatedMinutesWatched)
                  
                  # Use area under traffic curve if slope is below limit and level over threshold
#                  if ((-estimationAverage/slope < 2 * constantTrafficDuration) & slope < 0) {
                  if ((-estimationAverage/slope < 2 * constantTrafficDuration) & slope < 0 & estimationAverage > minimumMinsPerDay) {
                              futureMinutes <-  as.numeric(-(estimationAverage^2) / (2*slope))
                        m <- "grad"
                  }
                  # Slope is above limit, use constant traffic model
                  else {
                        futureMinutes <-  mean(estimationTraffic$estimatedMinutesWatch) * constantTrafficDuration
                        m <- "const"
                  }
            }
            # Not enough data to estimate future minutes
            else {
                  futureMinutes <- 0
                  m <- "timeout"
            }
            
            estimatedValue <- (pastMinutes + futureMinutes) * minuteValue
            
      }

      # If there are not enough observations to estimate value
      else {
            estimatedValue <- as.numeric(NA)
            pastMinutes <- as.numeric(NA)
            futureMinutes <- as.numeric(NA)
            m <- "fewobs"
#            dayMins <- as.numeric(NA)
      }

#      estimatedValue
#      list(estvalue = estimatedValue, pastMinutes, futureMinutes, m, estimationAverage, slope)
      dayMins <- VIDEOxAGE[which(videoId == estimateForVideoId & day == estimationdate)]$estimatedMinutesWatched
      if (is.null(dayMins)) dayMins <- 0
      list(estvalue = estimatedValue, pastmin = pastMinutes, futuremin = futureMinutes, method = m, daymins = dayMins)
}
