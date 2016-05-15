setwd('~/Projets/katossky.github.io/data')
# devtools::install_github("hrbrmstr/overpass")
library(overpass)
library(dplyr)
library(plyr)
library(sp)
library(rgeos)
library(geojsonio)

Sweden  <- overpass_query("[out:xml];relation(1770999);(._;>;);out;")
Denmark <- overpass_query("[out:xml];relation(1911568);(._;>;);out;")
Germany <- overpass_query("[out:xml];relation(2795128);(._;>;);out;")
Norway  <- overpass_query("[out:xml];relation(2797378);(._;>;);out;")

# exemples
# https://github.com/hrbrmstr/overpass
# http://rpubs.com/hrbrmstr/overpass

# filter Sweden
# 1. create a bouding box whose south limits corresponds to the end of the EV3
#    in Sweden
bbox <- gEnvelope(Sweden)
bbox_polygons <- bbox@polygons
bbox_polygons[[1]]@Polygons[[1]]@coords <-
  bbox_polygons[[1]]@Polygons[[1]]@coords %>%
  as.data.frame %>%
  mutate(y=ifelse(y==min(y), 57.7015602, y)) %>%
  as.matrix
bbox <- SpatialPolygons(bbox_polygons)
# 1bis. check that is correct
plot(Sweden, col='grey55')
plot(gIntersection(Sweden, bbox), col='grey55')
plot(bbox, add=TRUE)
# 2. intersect
Sweden <- gIntersection(Sweden, bbox)
Sweden <- Sweden@lines[[1]]@Lines %>%
  llply(function(obj) Lines(list(obj), ID=runif(1,0,10000))) %>%
  SpatialLines

# merge all data in only one file
ev3 <- SpatialLines(c(Norway@lines, Sweden2@lines, Denmark@lines, Germany@lines))
plot(ev3)
plot(gLineMerge(ev3))
ev3 <- gLineMerge(ev3)

# 461 lines just now... which means 460 errors? (there should be no hole)
ev3@lines[[1]]@Lines %>% length
ev3@lines[[1]]@Lines[1]
ev3@lines[[1]]@Lines[2]

# simplify for plotting at big scale
ev3_simplified <- gSimplify(ev3, tol = 5)
plot(ev3_simplified)
ev3_simplified@lines[[1]]@Lines %>% length
# ev3_simplified <- 1:length(ev3_simplified@lines) %>%
#   data.frame(row.names = .) %>%
#   SpatialLinesDataFrame(ev3_simplified, data=., match.ID = FALSE)

# export simplified shape as geo_json
# library(rgdal)
geojson_write(ev3_simplified, file = 'ev3-simplified.geojson')
# writeOGR(ev3_simplified, 'ev3-simplified.json', layer="inputJSON", driver="GeoJSON", check_exists = FALSE)
