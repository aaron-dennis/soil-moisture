## Aaron Dennis
## The Pennsylvania State University


## An Inelegant Hack at Scraping Data from an Unfortunate Gathering of Shapefiles


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
  data <- data[2]
}

# Read in arbitrary data to define ecoregion data frame and row names
statistic <- getStat(data.folders[1])
data.rows <- getData(data.folders[1])

# Set up empty data frames
mean.data <- as.data.frame(data.rows[0])
sd.data <- as.data.frame(data.rows[0])
ecoregion.names <- data.rows[0]
row.names(ecoregion.names) <- NULL

# Loop through folders and append data to ecoregions data
for (i in 1:length(data.folders)) {
  statistic <- getStat(data.folders[i])
  date <- getDate(data.folders[i])
  data <- getData(data.folders[i])
  colnames(data) <- date
  print(paste(date, statistic))
  if (statistic == "mean") {
    mean.data <- append(mean.data, data)
  }
  else if (statistic == "sd") {
    sd.data <- append(sd.data, data)
  }
  else {
    print(paste("error with", statistic, date))
  }
}

mean.df <- as.data.frame(mean.data, header = TRUE)
sd.df <- as.data.frame(sd.data)

mean.sample <- read.dbf(paste("~/soil-moisture/ecoregions-data/level3/", data.folders[1], "/SM_", "Mean", ".dbf", sep = ""))

ecoregions.mean <- c()
ecoregions.mean <- mean.sample$Ecoregion

row.names(mean.df) <- ecoregions
row.names(sd.df) <- ecoregions


sd.sample <- read.dbf(paste("~/soil-moisture/ecoregions-data/level3/", data.folders[2], "/SM_", "SD", ".dbf", sep = ""))

ecoregions.sd <- c()
ecoregions.sd <- sd.sample$Ecoregion

row.names(mean.df) <- ecoregions.mean
row.names(sd.df) <- ecoregions.sd

write.csv(mean.df, "~/soil-moisture/ecoregions-data/level3-mean.csv")
write.csv(sd.df, "~/soil-moisture/ecoregions-data/level3-sd.csv")

# Okay, so that got a little crazy. Lets bring in those CSV files and clean stuff up...

rm(list = ls())

# Working with the mean data...
mean <- read.csv("~/soil-moisture/ecoregions-data/level3-mean.csv", header = TRUE, row.names = 1, sep = ",", dec = ".")

mean <- as.matrix(mean)
mean <- round(mean, 1)

# Working with the standard deviation data...
sd <- read.csv("~/soil-moisture/ecoregions-data/level3-sd.csv", header = TRUE, row.names = 1, sep = ",", dec = ".")

sd <- as.matrix(sd)
sd <- round(sd, 1)

# Recreate the newly rounded CSV files
write.csv(mean, "~/soil-moisture/ecoregions-data/level3-mean.csv")
write.csv(sd, "~/soil-moisture/ecoregions-data/level3-sd.csv")