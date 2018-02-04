# Configuration file for YouTubeInsights
# Add configuration information below (shown as in <>) and rename this file to config.R

# Channels to be included
channels <- data.table(NULL)
channels <- rbind(channels, data.frame(channelName = "<Channelname1>",       channelId = "<ChannelID1>", extract = TRUE))
channels <- rbind(channels, data.frame(channelName = "<Channelname2>",       channelId = "<ChannelID2>", extract = TRUE))
# etc.

extractChannels <- channels[which(channels$extract)]

# Date range
earliestdate <- "1970-01-01"
latestdate <-   "2018-01-22"

# Countries included in detailed statistics
countries <- c("AR", "AT", "AU", "BE", "BR", "CA", "CH", "CL", "CZ", "DE", "DK", "ES", "FI", "FR", "GB",
               "HR", "IE", "IT", "MX", "NL", "NO", "NZ", "PL", "PT", "SE", "SI", "SK", "US")

# Data tables to include in data extraction
datatables <- c(
      "captions",
      "channels",
      "localizations",
      "playbacklocations",
      "tags",
      "trafficsources",
      "videoByCountryDetails",
      "videoByCountryTotals",
      "videos",
      "videostats"
)

# Data directory
datadir <- "<data directory>"

# Data file
datafile <- "YouTube.RData"

# API credentials
google.client.id = "<Your client ID>"
google.client.secret = "<Your client secret>"