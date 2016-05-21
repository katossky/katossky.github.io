setwd('~/Projets/katossky.github.io/data')

# STEP 1 DOWLOAD

# install_packages(c('devtools', 'sp'))
# devtools::install_github("hrbrmstr/overpass")
# exemples: http://rpubs.com/hrbrmstr/overpass

library(overpass)
library(sp)

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

Sweden  <- query(1770999)
Denmark <- query(1911568)
Germany <- query(2795128)
Norway  <- query(2797378)

# STEP 2 FILTER SWEDEN

# install_packages('rgeos')
library(rgeos) # for gEnvelope and gIntersection

# get a sp square that contains the Swedish track
bbox          <- gEnvelope(Sweden)

# get the y coordinates of the only polygon
# component
str(bbox)
bbox_polygons <- bbox@polygons[[1]]
bbox_polygon  <- bbox_polygons@Polygons[[1]]
y             <- bbox_polygon@coords[,'y']

# modify the coordinates of the square
y[y==min(y)]                <- 57.7015602
bbox_polygon@coords[,'y']   <- y
bbox_polygons@Polygons[[1]] <- bbox_polygon
# sp object "SpatialPolygons" has integrity
# constraints ; it's then better use the
# constructor
bbox <- SpatialPolygons(list(bbox_polygons))

# visualize the part of the track to be cropped
plot(Sweden, col='grey')
plot(bbox, add=TRUE)

# intersect the Swedish track with the new
# bounding box
Sweden <- gIntersection(Sweden, bbox)
# let's check that the line is correctly cropped
plot(Sweden, col='grey')
plot(bbox, add=TRUE)

# STEP 3 BUNDLING

# gIntersection returns all the segments as only
# one "Lines" object containing many "Line"
# objects whereas Denmark, Germany and Norway
# tracks are made of several "Lines" made of each
# one and only one "Line"

# extract the list of "Line" objects that
# constitute the first and only one "Lines" object
Sweden_lines <- Sweden@lines[[1]]@Lines
# create a list of "Lines" objects, with each one
# "Line" ; since an identifier is needed, I chose
# to randomly create them ; the code may randomly
# break in the event - unlikely but possible -
# where twice the same idenfier is chosen
big_number   <- 10e10
Sweden_lines <- lapply(Sweden_lines,
  function(line) Lines(
    slinelist = list(line),
    ID        = sample.int(n=big_number, size=1)
  )
)
Sweden <- SpatialLines(Sweden_lines)

# merge the 4 tracks into a unique "SpatialLines" object
EV3 <- SpatialLines(c(
  Norway@lines,
  Sweden@lines,
  Denmark@lines,
  Germany@lines
))
plot(EV3)
length(EV3@lines) # 5329 "Lines" objects

# merge the adjacent "Line" objects with each other
EV3 <- gLineMerge(EV3)
plot(EV3) # no change
length(EV3@lines)            #   1 "Lines" object
length(EV3@lines[[1]]@Lines) # 441 "Line"  objects
# 441 "Line" objects is 440 too many!

# simplify the shape for plotting at small scale
plot(EV3, xlim=c(6.6241494,7.0196573), ylim=c(50.936543, 51.2324358))
EV3_simple <- gSimplify(EV3, tol = 0.05)
plot(EV3_simple, col='red', add=TRUE)

plot(EV3, xlim=c(6.6241494,7.0196573), ylim=c(50.936543, 51.2324358))
EV3_simple <- gSimplify(EV3, tol = 0.01)
plot(EV3_simple, col='red', add=TRUE)

plot(EV3, xlim=c(6.6241494,7.0196573), ylim=c(50.936543, 51.2324358))
EV3_simple <- gSimplify(EV3, tol = 0.002)
plot(EV3_simple, col='red', add=TRUE)

# export as geoJSON
# install.packages('geojsonio')
library(geojsonio)
geojson_write(EV3, file = 'ev3.geojson')