setwd('~/Projets/katossky.github.io/data/2016-05-19-germany-on-track')

# STEP 1: GPX importation

library(dplyr) # for chaining with %>%
               # f(a,b) is the same as a %>% f(b)
               # or b %>% f(a, .)

# download the file from there:
# http://www.radnetz-deutschland.de/en/d-routen/d-route-7.html
# and store the file as 'dnetz.gpx'

# list the layers
library(sp)
library(rgdal)
ogrListLayers('dnetz.gpx')

# read the data
germany <- readOGR(
  'dnetz.gpx',
  layer='tracks'
)

# export them as geoJSON
library(geojsonio)
geojson_write(
  germany,
  file = 'dnetz.geojson'
)

# STEP 2: OpenStreetMap import

library(overpass)
library(geojsonio)

geojson_write(
  overpass_query('[out:xml]; relation(2795128);(._;>;);out;'),
  file = 'osm.geojson'
)