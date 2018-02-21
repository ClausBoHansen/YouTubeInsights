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

# Countries/languages to be included in analysis of effect of subtitles
countryLanguages <- data.table(NULL)
countryLanguages <- rbind(countryLanguages, data.frame(country = "AT", language = "de"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "AU", language = "en"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "DE", language = "de"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "DK", language = "da"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "ES", language = "es"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "FI", language = "fi"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "FR", language = "fr"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "GB", language = "en"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "HR", language = "hr"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "IE", language = "en"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "IT", language = "it"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "NL", language = "nl"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "NO", language = "no"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "NZ", language = "en"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "PL", language = "pl"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "SV", language = "sv"))
countryLanguages <- rbind(countryLanguages, data.frame(country = "US", language = "en"))

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
