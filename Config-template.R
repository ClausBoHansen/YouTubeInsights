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
maximumSlope            <- -0.01    # Slope values greater than this limit will be considered constant at intercept value
constantTrafficDuration <- 360      # Constant traffic videos will be attributes traffic this many days, if age is less than this number
minimumObservations     <- 50       # Minimum number of days required to estimate video value

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