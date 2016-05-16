---
layout:     page
title:      The track - importation
categories: [Eurovelo 3 - The making of]
tags:       [leaflet.js, OverPass API, regular expressions, OSM relations, OpenStreetMap]
thumbnail:  
summary:    The tracks of Eurovelo 3 as they exist on OpenStreetMap
---

Today is **the** day: the day where my <a href="">Eurovelo 3 project</a> comes to life. I just downoloaded all available data aout the route from OpenStreetMap, cleaned it, and published it. From now on, I will "just" have to edit data on OpenStreetMap and reimport the data for the map to be automatically updated.

I've already talked about <a href="">how to import data from OpenStreetMap</a>. But now, the problem is not only to plot the raw data, but to filter them and publish them in a beautiful way.

First step, downloading all available data. In <a href="">my latest post on the subject</a>, we realised that looking in OpenStreetMap's database for all objects containing the keyword "Eurovelo 3" leads:

- to missing some tracks listed with other keywords, such the part of the route between Oslo and Gothenburg, recorded as part of Eurovelo 12 rather than Eurovelo 3 ;
- to fetching undesired results, such a duplicate itinirary in Danmark.

Both issues have to be confronted on an *ad hoc* basis, by manually editting the list of objects (or "relations" in OpenStreetMap's dialect) returned by a simple request. On <a href="http://overpass-turbo.eu">Overpass Turbo</a>, the request:

    relation[name~"[Ee](uro)?[Vv](elo)? ?3"];
    out tags;

... returns 14 relations, only 3 of which correspond to an actual portion of the Eurovelo 3 route: in Norway (relation n°`2797378`), Denmark (`1911568`) and Germany (`2795128`).

On the other hand, completing the route when data exists but is listed under different keywords requires one additional step, namely to visit <a href="">the Eurovelo website</a> and find out which parts of Eurovelo 3 are shared with other Eurovelo routes. There are actually 3 of them: Eurovelo 12 between Oslo (Norway) and Gothenburg (Sweden) ; Eurovelo 6 between Orléans (France) and Tours (France) ; Eurovelo 1 between Pamplona (Spain) and Burgos (Spain).

The requests:

    relation[name~"[Ee](uro)?[Vv](elo)? ?1[^0-9]"];
    out tags;

    relation[name~"[Ee](uro)?[Vv](elo)? ?6"];
    out tags;

    relation[name~"[Ee](uro)?[Vv](elo)? ?12"];
    out tags;

... reveal that Eurovelo 1 is registered solely in France and Norway (and thus not between Pamplona and Burgos); that Eurovelo 6 is recorded almost everywhere *but* between Orléans and Tours ; and that the route in Sweden is relation n°`1770999`.

Then I can use <img src="/img/logos/r.png" title='R'> to collect the data directly from Overpass thanks to the <a href="">overpass</a> package<label for="sn-source-adfc" class="sidenote-number margin-toggle"></label><input type="checkbox" id="sn-source-adfc" class="margin-toggle"/><aside class="sidenote">See https://github.com/hrbrmstr/overpass and http://rpubs.com/hrbrmstr/overpassSome for exemples.</aside>:

    # install_packages(c('devtools', 'sp'))
    # devtools::install_github("hrbrmstr/overpass")

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

But Eurovelo 12 in Sweden only shares a limited part of the route with Eurovelo 3. I remove all tracks south of latitude `57.7015602`. (Handling spatial objects in <img src="/img/logos/r.png" title='R'> is maybe not the easiest task. The `sp` package is here unavoidable. But a seemingly simple task as modifying only a few points of an `sp` object, as we are here forced to do, ofetn requires to understand the struturing of `sp`-objects. Many of the most common spatial operations, such as intersection of shapes, are provided by the `rgeos` package.)

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

Last but not least, we must bundle the 4 tracks together, and export them together as one `geoJSON` file. Indeed, the Javascript library I am using for rendering the map, <img src="/img/logos/leaflet.png" title='Leaflet'>, does not read <img src="/img/logos/r.png" title='R'> files.

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

    # merge the 4 tracks into a unique "SpatialLines"
    # object
    EV3 <- SpatialLines(c(
      Norway@lines,
      Sweden@lines,
      Denmark@lines,
      Germany@lines
    ))
    plot(EV3)
    length(EV3@lines) # 5329 "Lines" objects

    # merge the adjacent "Line" objects with each
    # other
    EV3 <- gLineMerge(EV3)
    plot(EV3) # no change
    length(EV3@lines)            #   1 "Lines" object
    length(EV3@lines[[1]]@Lines) # 441 "Line"  objects
    # 441 "Line" objects is 440 too many!

    # simplify the shape for plotting at small scale
    EV3 <- gSimplify(EV3, tol = 3)
    # does not work well because of all the
    # disconnected lines
    plot(EV3)

    # export as geoJSON
    # install.packages('geojsonio')
    library(geojsonio)
    geojson_write(EV3, file='ev3-simplified.geojson')

That's done! You can go and admire the result [here](/eurovelo.html).

There are of course some details to improve. Most importantly, many lines are disconnected whereas they should actually be part of the same path. It has numerous consequences, such as:

- visible gaps on the map ;
- poor line simplification ; since each line has few points, there is often only one way to simplify: transform it to a segment;
- poor rendering ; on the map, a line is typically rendered as transparent and if the line is broken, then the extremities become very visible.

Other issues include duplicated parts of the itinirary or stand-alone points outside of the itinirary.

<div>
  <img src="/img/screenshots/2016-05-15-disconnected-lines-north-jutland.png" title="Detail of BVA's ADFC Radturenkarte near Rostock (Germany)">
  <p class='legend'><strong>Detail of Eurovelo 3 in North Jutland. </strong>Disconnected lines artificially darken the line's extremeities (in yellow). But this is not the only problem with OpenStreetMap data. Other issues include repeated information (in blue) and actual missing information (in red). Notice also that each individual line is acutally simplified as a segment.</p>
</div>

Before to start recording and correcting data in OpenStreetMap, the only fix I can quickly develop is to merge lines whose ending points are relatively close to each other. As far as I know, the simpler solution requires the use of <img src="/img/logos/qgis.png" title='Q'>GIS and its `joinmultiplelines` pluggin. But this is an other story.