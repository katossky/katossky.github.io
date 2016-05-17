---
layout:     page
title:      Importing the Namur-Tours GPS track
categories: [Eurovelo 3 - The making of]
tags:       [leaflet.js, gpx (format), rgeos (R package), geojsonio (R package), xml2 (R package), Namur, Tours, CycloTransEurope, Chamina]
thumbnail:  /img/thumbnails/importing-the-namur-tours-gps-track.png
summary:    A conversion from GPX to geoJSON with R.
---

<aside>
  <a href="http://www.chamina.com/produit/namur-tours-a-velo-de-la-belgique-a-263"><img src="/img/2016-05-16-topo-namur-tours.jpg" class='map-guide'></a>
  <p class='legend'><strong><img src="/img/logos/chamina.png" title="Chamina">'s topoguide from Namur to Tours.</strong> It was realised by the folks from CycloTransEurope. On [eurovelo3.fr](http://eurovelo3.fr/eurovelo3/), they release a lot of information -- including [the GPS tracks](http://eurovelo3.fr/services?service=download-gpx&rid=1) -- but you can support them by buying the guide.</p>
</aside>

In the process of mapping [the whole itinerary of route Eurovelo 3](/eurovelo.html) from Trondheim to Santiago de Compostella, I started [in a first post]() by downloading data from OpenStreetMap. But [in a precedent post](), we saw that these data are incomplete, missing the totality of France, Belgium and Spain. For those countries, we have no choice but to resort to alternative data sources, if they exist.

Luckily, the folks behind the French [CycloTransEurope](https://www.facebook.com/TransEuropeenne-117055065001991) association have done a great work at collecting information about Eurovelo tracks both in France and Belgium, while they were editing a topoguide for <img src="/img/logos/chamina.png" title="Chamina">. They even alow one to [download the GPS track](http://eurovelo3.fr/services?service=download-gpx&rid=1) from Namur (Belgium) to Tours (France). The rest of the route, between Tours and Irun (Spain), is to be published this summer -- at least that's what said to me Brunaud Devillard when I wrote [CycloTransEurope](https://www.facebook.com/TransEuropeenne-117055065001991) to inform them about [my future trip](/2016-01-01-the-pilgrim-road).

In this post, I will show how to download the [`GPX`](https://en.wikipedia.org/wiki/GPS_Exchange_Format) track and convert it to [`geoJSON`](http://geojson.org) with <img src="/img/logos/r.png" title='R'>. The simpler is to use the [`rgdal`](https://cran.r-project.org/web/packages/rgdal/index.html) package. But for those who do not want to use the [`gdal`](http://www.gdal.org/) library -- whose installation can be time consuming -- I will also provide an alternative possibility.

<strong>Method 1. </strong>Quite transparently, the `rgdal` package is an interface with the `gdal` library, which provides a wide range of drivers for reading and writing spatial data. The exact list of all available drivers is given within <img src="/img/logos/r.png" title='R'> by `ogrDrivers()`. In case the `GPX` was not included in the list, please see the alternative solution.

<aside class='remark'><p>The handling of spatial objects in <img src="/img/logos/r.png" title='R'> requires the `sp` package. However, its use can be tricky. For a extensive overview of the `sp` package and to geographical information in <img src="/img/logos/r.png" title='R'>, see [this presentation of Roger Bivand](http://geostat-course.org/system/files/monday_slides.pdf). The most common tasks also requires [`rgdal`](https://cran.r-project.org/web/packages/rgdal/index.html) for reading, writing and converting between different formats and [`rgeos`](https://cran.r-project.org/web/packages/rgeos/index.html) for common operations such as intersection, simplification, area computation, etc.</p></aside>

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
        file = 'namurs-tours.geojson'
    )

Now, the file can be rendered seamlessly with <img src="/img/logos/leaflet.png" title='Leaflet'> onto a map.

<div class='wide'>
  <div id='map'></div>
  <p class='legend'>**Even and uneven lines.** When the data is imported as only one track -- as here with the GPS track between Namur (Belgium) and Tours (France), the display is even, with one plain, smooth line. On the contrary, the data extracted from OpenStreetMap is made of several hundred of smaller tracks, hence the unhomogenous rendering.</p>
</div>

<strong>Method 2. </strong>The other solution takes advantage of the very definition of the [`GPX`](https://en.wikipedia.org/wiki/GPS_Exchange_Format) format, which is just a variety of [`XML`](http://www.w3schools.com/xml). We can thus use the [`xml2`](https://github.com/hadley/xml2) package and build the `sp` object from scratch.

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
      file = 'namurs-tours.geojson'
    )

<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('map', {
    minZoom: 4,
    touchZoom: false,
    scrollWheelZoom: false,
    center: [50, 6],
    zoom: 6
  })
  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
attribution: 'Tiles &copy; Esri'}).addTo(map);

  $.getJSON("/data/2016-05-17-ev3.geojson", function(data) {
    console.log(data);
    L.geoJson(data).addTo(map);
  });

  $.getJSON("/data/2016-05-17-namur-tours.geojson", function(data) {
    console.log(data);
    L.geoJson(data).addTo(map);
  });

 </script>