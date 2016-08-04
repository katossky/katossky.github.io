setwd('~/Projets/katossky.github.io/data/journey-planner')

library(geojsonio)
library(sp)
library(rgdal)
library(geosphere)
library(dplyr)
library(data.table)

source('2016-06-20-michelin-restaurants.RData')

Restaurants_sp <- RESTAURANTS %>% select(
  name, url, stars, bib_gourmand, best_addresses, twenty_or_less, website, lon, lat
)
coordinates(Restaurants_sp) <- ~lon+lat
proj4string(Restaurants_sp) <- CRS("+init=epsg:4326")

# filter out restaurants too far away from the eurovelo route
ogrListLayers('ev3.geojson')
ev3 <- readOGR(dsn='ev3.geojson', layer='OGRGeoJSON')
Restaurants_sp$distance_to_ev3 <- dist2Line(Restaurants_sp, ev3)[,'distance']
Restaurants_sp_filtered <- Restaurants_sp[Restaurants_sp$distance_to_ev3<=30000,]

geojson_write(
  Restaurants_sp_filtered,
  file = paste0(Sys.Date(),'-michelin-restaurants.geojson')
)