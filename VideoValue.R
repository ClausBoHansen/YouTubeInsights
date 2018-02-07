# Estimate value of video

# Load libraries
library(data.table)
library(lubridate)

source("Config.R")

sigmoid <- function(relslope, age) {
      # Calculates correction factor for estimate of future watch minutes
      min(1, 1 + (standardLifetime/(standardLifetime + 3 * age)) * (relslope / (1 + abs(relslope))))
}

get.video.value <- function(estimateForVideoId, estimationdate = latestdate, minobs = minimumObservations) {

      videoTraffic <- VIDEOxAGE[which(videoId == estimateForVideoId & day < estimationdate)]
      observations <- nrow(videoTraffic)
      
      pastMinutes <- as.numeric(NULL)
      futureMinutes <- as.numeric(NULL)
      m <- NULL
      slope <- NULL
      intercept <- NULL
      estimationAverage <- NULL
      relativeslope <- NULL
      estimatedRemainingLifetime <- NULL
      
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
                  intercept <- model$coefficients[1]
                  slope <- model$coefficients[2]
                  estimationAverage <- mean(estimationTraffic$estimatedMinutesWatched)

                  # Calculate relative slope
                  relativeslope <- as.numeric(minobs*slope/estimationAverage)
                  
                  # Calculate estimated remaining lifetime
                  initialAverage <- mean(videoTraffic[1:minobs,]$estimatedMinutesWatched)
                  estimationAverageDate <- mean(estimationTraffic$day)
                  initialAverageDate <- mean(videoTraffic[1:minobs,]$day)
                  
                  # Calculate difference in days between initial average and estimation average
                  estimationAge <- as.numeric(estimationAverageDate-initialAverageDate)
                  
                  # Age of video, since first view
                  age <- as.numeric(date(estimationdate) - date(videoTraffic[which.min(day)]$day))

                  # Estimated remaining lifetime                  
                  estimatedRemainingLifetime <- min(maximumLifetime - age, max(standardLifetime - age, estimationAge * (estimationAverage/initialAverage)))

                  # Estimated future minutes
                  futureMinutes <- estimationAverage * estimatedRemainingLifetime * sigmoid(relativeslope, age)
                  
                  m <- "sigmoid"

            }
            # Not enough data to estimate future minutes
            else {
                  futureMinutes <- 0
                  m <- "timeout"
            }

            # Total estimated value of video            
            estimatedValue <- (pastMinutes + futureMinutes) * minuteValue

      }

      # If there are not enough observations to estimate value
      else {
            estimatedValue <- as.numeric(NA)
            pastMinutes <- as.numeric(NA)
            futureMinutes <- as.numeric(NA)
            m <- "fewobs"
      }

      # Minutes watch on estimation date
      dayMins <- VIDEOxAGE[which(videoId == estimateForVideoId & day == estimationdate)]$estimatedMinutesWatched
      if (length(dayMins) == 0) dayMins <- 0
      
      # Return result
      list(estvalue = estimatedValue, pastmin = pastMinutes, futuremin = futureMinutes, method = m, daymins = dayMins, relslope = relativeslope, restlife = estimatedRemainingLifetime)
}
