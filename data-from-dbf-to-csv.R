## Aaron Dennis
## The Pennsylvania State University

## This R script is intended to read attribute information of a large set of
# shapefiles and write that information to a more manageable CSV file. The 
# shapefiles are stored in folders containing information about the date and
# statistic relevant its shapefile. Each folder contains a DBF file with a column
# of ecoregion names and a column of corresponding mean or standard deviation values.


# Clear the environment
rm(list = ls())

# Install and require packages
#install.packages("foreign")
library(foreign)

# Read ecoregions ID and name data
ecoregions.data <- read.csv("~/soil-moisture/ecoregions-data/ecoregions.csv", row.names = "US_L3NAME")

ecoregions.mean <- ecoregions.data
ecoregions.sd  <- ecoregions.data

# Identify working directory
wd <- "~/soil-moisture/ecoregions-data/level3/"

# Read data folders for DBF file metadata
data.folders <- list.files(wd)

# Define function to extract date from folder name
getDate <- function(folder.name) {
  as.Date(substr(folder.name, 4, 11), "%Y%m%d")
}

# Define function to extract type of statistic (either mean or standard deviation)
getStat <- function(folder.name) {
  substr(folder.name, 13, nchar(folder.name))
}

# Define function to read file DBF and return as dataframe
getData <- function(folder.name) {
  data <- read.dbf(paste("~/soil-moisture/ecoregions-data/level3/", folder.name, "/SM_", statistic, ".dbf", sep = ""))
  row.names(data) <- data$Ecoregion
  data <- data[2]
}

# Loop through folders and append data to ecoregions data
for (i in 1:length(data.folders)) {
  statistic <- getStat(data.folders[i])
  date <- getDate(data.folders[i])
  data <- getData(data.folders[i])
  colnames(data) <- date
  if (statistic == "mean") {
    ecoregions.mean <- merge(ecoregions.mean, data, by = "row.names")
  }
  else if (statistic == "sd") {
    ecoregions.sd <- merge(ecoregions.sd, data, by = "row.names")
  }
  else {
    print(paste("error with", statistic, date))
  }
}
?merge
