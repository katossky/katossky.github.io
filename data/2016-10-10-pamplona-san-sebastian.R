setwd('~/Projets/katossky.github.io/data')

# list the layers
library(sp)
library(rgdal)
ogrListLayers('2015-09-pamplona-san-sebastian.gpx')

# read the data
pss <- readOGR(
  '2015-09-pamplona-san-sebastian.gpx',
  layer='tracks'
)

library(geojsonio)
geojson_write(
  pss,
  file = '2015-09-pamplona-san-sebastian.geojson'
)
