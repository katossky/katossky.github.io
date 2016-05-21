setwd('~/Projets/katossky.github.io/data')

library(dplyr) # for chaining with %>%
               # f(a,b) is the same as a %>% f(b)
               # or b %>% f(a, .)

# the data is downloaded from this website (login required)
# http://www.biroto.eu/en/cycle-route/europe/eurovelo-pilgrims-route-ev3/rt00000408
# and stored under the name 'ev3-biroto.gpx'

# list the layers
library(sp)
library(rgdal)
ogrListLayers('2016-05-21-ev3-biroto.gpx')

# read the data
ev3 <- readOGR(
  '2016-05-21-ev3-biroto.gpx',
  layer='tracks'
)

# export them as geoJSON
library(geojsonio)
geojson_write(
  ev3,
  file = 'ev3.geojson'
)