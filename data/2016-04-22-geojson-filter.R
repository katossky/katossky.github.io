setwd('Projets/katossky.github.io/data')
library(dplyr)
library(stringr)
library(jsonlite)
# readLines('2016-04-22-overpass-API.geojson') # working
# Data <- geojson_read('2016-04-22-overpass-API.geojson') # not working
fromJSON('2016-04-22-overpass-API.geojson') %>%
  with(features <- features[str_detect(features$properties$`@id`, '^way'),]) %>%
  toJSON %>%
  cat(file ='2016-04-22-overpass-API-filtered.geojson')