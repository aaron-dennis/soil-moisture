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


data <- read.dbf("/Users/aarondennis/soil-moisture/ecoregions-data/level3/SM_20060605_mean/SM_Mean.dbf")