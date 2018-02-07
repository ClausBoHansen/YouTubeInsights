# Configuration file for YouTubeInsights
# Add configuration information below (shown as in <>) and rename this file to config.R

# Channels to be included
channels <- data.table(NULL)
channels <- rbind(channels, data.frame(channelName = "<Channelname1>",       channelId = "<ChannelID1>", extract = TRUE))
channels <- rbind(channels, data.frame(channelName = "<Channelname2>",       channelId = "<ChannelID2>", extract = TRUE))
# etc.

extractChannels <- channels[which(channels$extract)]

# Value model parameters
minuteValue             <- 0.5      # Value (€) of one minute video played
standardLifetime        <- 360      # The average expected lifetime for a video (days)
maximumLifetime         <- 1080     # The maximum lifetime for a video (days). Estimation of future traffic will not exceed this limit.
minimumObservations     <- 90       # Minimum number of days required to estimate video value
minimumMinsPerDay       <- 10       # When average mininutes per day drops below this level, constant prediction is used
maxDaysSinceObservation <- 10       # If there has not been an observation for this number of days, no future value estimate will be added

# Date range
earliestdate <- "1970-01-01"
latestdate <-   "2018-01-22"

# Countries included in detailed statistics
countries <- c("AR", "AT", "AU", "BE", "BR", "CA", "CH", "CL", "CZ", "DE", "DK", "ES", "FI", "FR", "GB",
               "HR", "IE", "IT", "MX", "NL", "NO", "NZ", "PL", "PT", "SE", "SI", "SK", "US")

# Data tables to include in data extraction
datatables <- c(
      "captions",
      "localizations",
      "playbacklocations",
      "subscribers",
      "tags",
      "trafficsources",
      "videoByCountryDetails",
      "videoByCountryTotals",
      "videos",
      "videostats"
)

# Data directory
datadir <- "<data directory>"

# Data files
rawfile <- "rawData.RData"
processedfile <- "processedData.RData"

# API credentials
google.client.id = "<Your client ID>"
google.client.secret = "<Your client secret>"