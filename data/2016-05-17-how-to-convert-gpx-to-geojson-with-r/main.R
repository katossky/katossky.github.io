setwd('~/Projets/katossky.github.io/data/2016-05-17-how-to-convert-gpx-to-geojson-with-r')

# METHOD 1

library(dplyr) # for chaining with %>%
               # f(a,b) is the same as a %>% f(b)
               # or b %>% f(a, .)

# remove the first (empty) line
# and store the file as 'namur-tours.gpx'
'http://eurovelo3.fr/services?' %>%
  paste0('service=download-gpx&rid=1') %>%
  readLines %>%
  last %>%
  cat(file='namur-tours.gpx')

# list the layers
library(sp)
library(rgdal)
ogrListLayers('namur-tours.gpx')

# read the data
namur_tours <- readOGR(
  'namur-tours.gpx',
  layer='tracks'
)

# export them as geoJSON
library(geojsonio)
geojson_write(
  namur_tours,
  file = 'namur-tours.geojson'
)

# METHOD 2

library(dplyr) # for chaining with %>%

# read as XML file
library(xml2)
namur_tours <-
  'http://eurovelo3.fr/services?' %>%
  paste0('service=download-gpx&rid=1') %>%
  readLines %>%
  last %>%
  read_xml

# extract coordinates of points
# points are recorded as 'trkpt' (trackpoint)
# in the namespace 'd1'
namur_tours_ns     <- xml_ns(namur_tours)
namur_tours_pts    <- namur_tours %>% xml_find_all(
  "//d1:trkpt",
  namur_tours_ns
)
namur_tours_lat    <- namur_tours_pts %>%
  xml_attr('lon')
namur_tours_long   <- namur_tours_pts %>%
  xml_attr('lat')
namur_tours_coords <- cbind(
  longitude =  as.numeric(namur_tours_lat),
  latitude  =  as.numeric(namur_tours_long)
)

# build the SpatialLine object
library(sp)
namur_tours_line  <- Line(namur_tours_coords)
namur_tours_lines <- Lines(namur_tours_line, "NT")
namur_tours       <- SpatialLines(
  LinesList   = list(namur_tours_lines),
  proj4string = CRS("+init=epsg:4326")
)

# export them as geoJSON
library(geojsonio)
geojson_write(
  namur_tours,
  file = 'namur-tours.geojson'
)