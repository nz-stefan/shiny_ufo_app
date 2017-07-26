###########################################################
# Provide functionality to map coordinates (lng, lat) to
# countries and continents.
#
# Code adapted from: 
# https://stackoverflow.com/questions/21708488/get-country-and-continent-from-longitude-and-latitude-point-in-r/21727515
# 
# Author: Stefan Schliebs
# Created: 2017-07-27
###########################################################


library(sp)
library(rworldmap)

# The single argument to this function, points, is a data.frame in which:
#   - column 1 contains the longitude in degrees
#   - column 2 contains the latitude in degrees
coords2continent <- function(points) {  
  countriesSP <- getMap(resolution='low')

  # converting points to a SpatialPoints object
  # setting CRS directly to that from rworldmap
  pointsSP <- SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  

  # use 'over' to get indices of the Polygons object containing each point 
  indices <- over(pointsSP, countriesSP)

  # indices$continent   # returns the continent (6 continent model)
  # indices$REGION   # returns the continent (7 continent model)
  # indices$ADMIN  #returns country name
  # indices$ISO3 # returns the ISO3 code 
  
  indices
}


# Some tests --------------------------------------------------------------

points <- data.frame(lon=c(0, 90, -45, -100, 130, 174.762786), lat=c(52, 40, -10, 45, -30, -36.850073))
coords2continent(points) %>% View

# -> looking good!
