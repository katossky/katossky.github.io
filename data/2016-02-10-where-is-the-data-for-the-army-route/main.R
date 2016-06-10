setwd('Projets/katossky.github.io/data/2016-02-10-where-is-the-data-for-the-army-route')

library(sp)
library(geojsonio)
library(rgdal)

# GPSies
geojson_write(
  readOGR('gpsies.gpx',  layer='tracks'),
  file = 'gpsies.geojson'
)

# kort.haervej.dk
geojson_write(
  readOGR('kort.haervej.dk.kml', 'Cykelrute'),
  file = 'kort.haervej.dk.geojson'
)

# OpenStreetMap
library(overpass)
query <- function(number){
  overpass_query(
    paste0(
      '[out:xml];',
      'relation(', number, ');',
      '(._;>;);',
      'out;'
    )
  )
}
geojson_write(query(1911568), file = 'osm.geojson')

# Biroto
geojson_write(
  readOGR('biroto.gpx',  layer='tracks'),
  file = 'biroto.geojson'
)