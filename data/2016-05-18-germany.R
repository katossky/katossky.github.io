setwd('~/Projets/katossky.github.io/data')

# STEP 1: GPX importation

library(dplyr) # for chaining with %>%
               # f(a,b) is the same as a %>% f(b)
               # or b %>% f(a, .)

# store the file as 'route-d7.gpx'
paste(
  'eID=tx_nawsecuredl',
  'u=0',
  'file=fileadmin/Redaktion/Dateien/D-Route_7/Tracks/D-Route7.gpx',
  't=1463668847',
  'hash=8937aaabac1003afcde14b04a65162cdf25eea22',
  sep = '&'
) %>%
  paste0('http://www.radnetz-deutschland.de/index.php?', .) %>%
  download.file('route-d7.gpx')

# list the layers
library(sp)
library(rgdal)
ogrListLayers('route-d7.gpx')

# read the data
germany <- readOGR(
  'route-d7.gpx',
  layer='tracks'
)

# export them as geoJSON
library(geojsonio)
geojson_write(
  germany,
  file = 'route-d7.geojson'
)

# STEP 2: OpenStreetMap import

library(overpass)
library(sp)

germany <- overpass_query('[out:xml]; relation(2795128);(._;>;);out;')
library(geojsonio)
geojson_write(germany, file = 'ev3-osm.geojson')