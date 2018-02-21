# Functions to support presentation

# Load libraries
library(pals)

# Input: Factor of classes to plot
# Output: vector of n color codes
get.palette <- function(plotclasses) {
      
      palette <- polychrome()[1:length(plotclasses)]
      palette

}