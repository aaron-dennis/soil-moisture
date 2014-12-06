## Aaron Dennis
## The Pennsylvania State University

## Soil Moisture Time Series Animation

# Clear workspace
rm(list = ls())

# Install packages if necessary
#install.packages("raster")
#install.packages("maptools")

# Load required packages
library(raster)
library(maptools)

### RETRIEVE DATA ###

# Path to soil moisture data location
tif.path <- "~/soil_moisture/SM_gap_filled_tif/"

# List of .tif soil moisture data files
tif.files <- list.files(tif.path, pattern = ".tif")

# List of .tif soil moisture data files by year
year.SM <- function(year) {
  result <- list()
  for (i in 1:length(tif.files)) {
    if (substr(tif.files[i], 4, 7) == year) {
      result <- append(result, tif.files[i])
    }
  }
}

# Read basemap data
ocean <- readShapePoly("~/soil_moisture/basemap_data/ocean.shp")
lakes <- readShapePoly("~/soil_moisture/basemap_data/lakes.shp")
countries <- readShapePoly("~/soil_moisture/basemap_data/neighboring_countries.shp")
state_boundaries <- readShapeLines("~/soil_moisture/basemap_data/state_boundaries.shp")

### PREPARE VISUAL DETAILS ###

# Define margins
par(mar = c(1,2,2.5,1))

# Define color ramp palette for map of wetness
color.ramp <- colorRampPalette(c(rgb(255,255,204, max = 255), 
                                 rgb(199,233,180, max = 255),
                                 rgb(127,205,187, max = 255), 
                                 rgb(65,182,196,  max = 255), 
                                 rgb(44,127,184,  max = 255), 
                                 rgb(37,52,148,   max = 255)), 
                               bias = 1.5, 
                               space = "Lab", 
                               interpolate = "spline")



### SOIL MOISTURE MAPPING FUNCTIONS ###

# Function to plot soil moisture map
mapSoilMoisture <- function(raster) {
  plot(raster,
       add = FALSE,
       breaks = seq(0, 500, by = 25),
       legend.width = 4,
       axes = FALSE,
       col = color.ramp(20),
       xlim = c(-2460000, 2408000),
       ylim = c(110000, 3380000),
       useRaster = TRUE,
       interpolate = TRUE)
  
  # Plot basemap layers
  plot(state_boundaries, 
       add = TRUE, 
       col = "white", 
       lwd = 0.8)
  plot(countries,
       add = TRUE,
       col = "grey",
       border = "white",
       lwd = 1.4)
  plot(ocean, 
       add = TRUE, 
       col = "lightblue",
       border = "lightblue")
  plot(lakes, 
       add = TRUE, 
       col = "lightblue",
       border = "lightblue")
}

# Collect dates for each dataset
plot.dates <- function(list) {
  dates <- list()
  for (i in 1:length(list)) {
    dates <- append(dates, as.Date(substr(list[i], 4, 11), "%Y%m%d"))
  }
  return(dates)
}

# Function to make .png images for soil moisture datasets
makeMaps <- function(list) {
  dates <- plot.dates(list)
  for (i in 1:length(list)) {
    png(file = paste("~/Desktop/SoilMoisturePlots/map", sprintf("%04d", i), ".png", sep = ""), 
        width = 1280, 
        height = 720)
    map <- raster(paste(tif.path, list[i], sep = ""))
    mapSoilMoisture(map)
    title(main = format(dates[i], format = "%B %d, %Y"), cex = 8, family = "Avenir")
    dev.off()
  }
}

# Write .png files for list
makeMaps(tif.files)

# Compile maps into video, depends on ffmpeg installation
system("ffmpeg -framerate 20 -i ~/Desktop/SoilMoisturePlots/map%04d.png ~/Desktop/Soil_Moisture.mp4")