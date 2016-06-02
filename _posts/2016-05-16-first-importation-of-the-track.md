---
layout:     post
title:      Importing the Eurovelo 3 track from OpenStreetMap
categories: [Journey Planner - The Making of]
tags:       [leaflet.js, OverPass API, OSM relations, OpenStreetMap, overpass (R package), rgeos (R package), geojsonio (R package)]
thumbnail:  /img/thumbnails/first-importation-of-the-track.png
summary:    A first attempt using R.
---


<aside>
  <img src="/img/eurovelo-3-route.png">
  <p class='legend'><strong>The official Eurovelo 3 route. </strong>« The Pilgrim Way » starts in Trondheim (Norway) and runs through Sweden, Denmark, Germany, crosses the Netherlands at Maastricht, continues across Belgium, France to enventually end in Spain in Santiago de Compostella.</p>
</aside>

<aside>
  <img src="/img/screenshots/2016-05-16-ev3-itinerary.png">
  <p class='legend'><strong>The itinerary as extracted from OpenStreetMap. </strong>The itinerary is not available in Belgium, France nor Spain. Notice two important holes in the available data: between Oslo and the North Sea coast in Norway; and between Bremen and Münster in Germany.</p>
</aside>

<aside>
  <img src="/img/screenshots/2016-05-15-overpass-turbo-EV3-EV12.png">
  <p class='legend'><strong>Latitude 57.7015602. </strong>While they share the route from Oslo to Gothenburg, Eurovelo 3 and Eurovelo 12 split in the center of Gothenburg. The first takes the ferry towards continental Denmark whereas the other continues south towards Scania. Since I rely on the track of Eurovelo 12 for this part of the itinerary, I must filter out all what is south from this place.</p>
</aside>

<aside>
  <img src="/img/screenshots/2016-05-16-holes-near-hamar.png">
  <p class='legend'><strong>Small holes in the itineray near Hamar (Norway). </strong>OpenStreetMap is not complete and there exist many small or big holes in the itinerary, many of which cannot be fixed in an automated way. Normally, <a href="https://wiki.openstreetmap.org/wiki/Routing">routes should be continuous</a> but the implementation of this policy is dependant on the good will of each and every map editor.</p>
</aside>

<aside>
  <img src="/img/screenshots/2016-05-16-visible-endpoints-near-dusseldorf.png">
  <p class='legend'><strong>Visible line endpoints near Düsseldorf (Germany). </strong>Currently, the outline of the route is neither even nor plain. On the contrary, the line is broken and the color is darker in angles.</p>
</aside>

<aside>
  <img src="/img/screenshots/2016-05-16-roundabout-near-dusseldorf.png">
  <p class='legend'><strong>Tiny discontinuity in the route at a roundabout near Düsseldorf (Germany). </strong>What is perceived as darker endpoints at small scale (see previous image) is actually a tiny discontinuity in the route. Since the lines are slightly transparent, their superposition creates darker zones. If the line was continuous, <img src="/img/logos/leaflet.png" title='Leaflet'> would render it seamlessly.</p>
</aside>

<aside>
  <img src="/img/screenshots/2016-05-16-oversimplified-line-near-dusseldorf.png">
  <p class='legend'><strong>A bad line approximation near Düsseldorf (Germany) forces cylists to swim twice across the Rhine. </strong>An unexpected consequence of line discontinuity is bad line approximation. Indeed, the shorter a line is, the most probable its approximation is a segment.</p>
</aside>

<aside>
  <img src="/img/screenshots/2016-05-16-double-lines-near-dusseldorf-zoom.png">
  <p class='legend'><strong>Dark-shaded bridge near Düsseldorf (Germany). </strong> Large roads — as here a highway bridge — are often rendered by two or more lines, one for each group of lanes. The unwanted consequence of this practice is a dark-shaded line at medium and small scale.</p>
</aside>

Today is **the** day: the day where my [Eurovelo 3 project](/eurovelo.html) comes to life. I just downloaded all the data about the route one can find on OpenStreetMap, cleaned it, and [published it](/eurovelo.html). There is of course much more work to come to enrich this first step but that is it: the first and most important step. This post an extended account of the process.

I have already talked about [how to import data from OpenStreetMap](). But now, the problem is not only to plot the raw data, but also to filter them so that only the information needed is present.

**First step, finding all available data.** In [my latest post on the subject](), we realised that looking in OpenStreetMap's database for all objects containing the keyword "Eurovelo 3" leads:

- to missing some tracks listed with other keywords, such as the part of the route between Oslo and Gothenburg, recorded as part of Eurovelo 12 rather than Eurovelo 3 ;
- to fetching undesired results, such as a duplicate itinerary in Danmark.

I confront both issues by manually editing the list of objects (or "relations" in OpenStreetMap's dialect) returned by a simple request. For instance, on [Overpass Turbo](http://overpass-turbo.eu), the request:

    relation[name~"[Ee](uro)?[Vv](elo)? ?3"];
    out tags;

... returns 14 *relations*, only 3 of which correspond to an actual portion of the Eurovelo 3 route: in Norway (relation n°[`2797378`](http://www.openstreetmap.org/relation/2797378)), Denmark ([`1911568`](http://www.openstreetmap.org/relation/1911568)) and Germany ([`2795128`](http://www.openstreetmap.org/relation/2795128)). I discard the others.

Similarly, I extend the list with other *relations* that depict the itinerary but under a different name. A bit of investigation is needed here. Visiting [the Eurovelo website](http://www.eurovelo.com/en/eurovelos) reveals that Eurovelo 3 share some of the route with the following itineraries: Eurovelo 12 between Oslo (Norway) and Gothenburg (Sweden) ; Eurovelo 6 between Orléans (France) and Tours (France) ; Eurovelo 1 between Pamplona (Spain) and Burgos (Spain).

The requests:

    relation[name~"[Ee](uro)?[Vv](elo)? ?1[^0-9]"];
    out tags;

    relation[name~"[Ee](uro)?[Vv](elo)? ?6"];
    out tags;

    relation[name~"[Ee](uro)?[Vv](elo)? ?12"];
    out tags;

... are disappointing. Eurovelo 1 is registered solely in France and Norway (and thus not between Pamplona and Burgos); Eurovelo 6 is recorded almost everywhere *but* between Orléans and Tours. The only good news is that the route in Sweden is recorded as *relation* n°[`1770999`](http://www.openstreetmap.org/relation/1770999).

**Second step, downloading and filtering.** Now that I know which *relations* I am interested in, I can use <img src="/img/logos/r.png" title='R'> to collect the data directly from Overpass thanks to the [`overpass`](https://github.com/hrbrmstr/overpass) package:

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

But the Swedish case is special: since Eurovelo 12 in Sweden only shares a limited part of the route with Eurovelo 3, I must remove all the route south of latitude `57.7015602`.

However, handling spatial objects in <img src="/img/logos/r.png" title='R'> is not as easy as imagined. The [`sp`](https://cran.r-project.org/web/packages/sp/index.html) package is here unavoidable, and also tricky to use. Filtering out the points with latitude smaller than `57.7015602` feels simple but surprisingly, it requires to understand in-depth the struture of `sp`-objects. I get a little help from the [`rgeos`](https://cran.r-project.org/web/packages/rgeos/index.html) package, at least for the most common spatial operations, such as intersection of shapes.

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

**Last but not least, we must bundle the 4 tracks together, and export them in a readable format.** Indeed, the Javascript library I am using for rendering the map, {{ include logo.md }}, reads `geoJSON` files.

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

That's done! Now let's just relax and admire the result of our efforts:

<div class='wide'><div id='map'></div></div>

There are of course some details to improve (see images on the right). Most importantly, many lines are disconnected whereas they should actually be part of the same path. It has numerous consequences, such as:

- visible gaps on the map ;
- poor line simplification ; since each line has few points, there is often only one way to simplify: transform it to a segment ;
- poor rendering ; on the map, a line is typically rendered as transparent and if the line is broken, then the extremities become very visible.

The cleanest way to solve these issues is to record and correct data directly in OpenStreetMap but a convenient fix could also be to merge lines whose ending points are relatively close to each other. <!--As far as I could read, the simpler solution requires the use of <img src="/img/logos/qgis.png" title='Q'>GIS and its `joinmultiplelines` pluggin.--> But this is an other story.

<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('map', {
    minZoom: 4,
    touchZoom: false,
    scrollWheelZoom: false,
    center: [58, 10],
    zoom: 4
  })
  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
attribution: 'Tiles &copy; Esri'}).addTo(map);

  $.getJSON("/data/2016-05-15-ev3-simplified.geojson", function(data) {
    console.log(data);
    L.geoJson(data).addTo(map);
  });

 </script>