setwd('Projets/katossky.github.io/data/2016-04-22-how-to-dowload-data-from-openstreetmap')

library(sp)
library(geojsonio)
library(rgdal)
library(overpass)

geojson_write(
  overpass_query("[out:xml];relation(299546);(._;>>;);out;"),
  file = 'osm.geojson'
)

library(dplyr)
library(stringr)
library(jsonlite)
fromJSON('export.geojson') %>%
  with(features <- features[str_detect(features$properties$`@id`, '^way'),]) %>%
  toJSON %>%
  cat(file ='osm2.geojson')