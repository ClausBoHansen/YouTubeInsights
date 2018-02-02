# Configuration file for YouTubeInsights
# Add configuration information below (shown as in <>) and rename this file to config.R

# Channels to be included
channels <- data.table(NULL)
channels <- rbind(channels, data.frame(Channelname = "<Channelname1>",       ChannelID = "<ChannelID1>"))
channels <- rbind(channels, data.frame(Channelname = "<Channelname2>",       ChannelID = "<ChannelID2>"))
# etc.

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

# API credentials
google.client.id = "<Your client ID>"
google.client.secret = "<Your client secret>"