---
layout:     post
title:      How to convert GPX to geoJSON with R?
categories: [Journey Planner - The Making of]
tags:       [leaflet.js, gpx (format), rgeos (R package), geojsonio (R package), xml2 (R package), Namur, Tours, CycloTransEurope, Chamina]
thumbnail:  /img/thumbnails/importing-the-namur-tours-gps-track.png
summary:    Folks behind the French CycloTransEurope association have done a great work at collecting information about Eurovelo tracks both in France and Belgium. They even alow us to download the GPS track from Namur (Belgium) to Tours (France). In this post, I will show how to download the GPX track and convert it to geoJSON with R.
---

<aside>
  <a href="http://eurovelo3.fr/cte/topo-guides/"><img src="/img/2016-05-16-topo-namur-tours.jpg" class='map-guide'></a>
  <p class='legend' markdown='1'>{% include logo.md what='chamina'%}**'s topoguide from Namur to Tours.** It was realised by the folks from {% include logo.md what='cyclotrans-europe' %}. They publish a lot of information for free on their website, [eurovelo3.fr](http://eurovelo3.fr/eurovelo3/) -- including [the GPS tracks](http://eurovelo3.fr/services?service=download-gpx&rid=1) -- but you can give your support by buying the guide [directly from them](http://eurovelo3.fr/cte/topo-guides).</p>
</aside>

Before I started to [import the whole itinerary of route *EuroVelo* 3]({% post_url 2016-02-10-where-is-the-data-for-the-army-route %}) from Trondheim to Santiago de Compostella, using *OpenStreetMap* data, I had already started collecting information about the itinerary from different sources.

For instance, the folks behind the French {% include logo.md what='cyclotrans-europe' %} association have done a great work at collecting information about *EuroVelo* tracks both in France and Belgium, while they were editing a topoguide for {% include logo.md what='chamina'%}. They even allow us to [download the GPS track](http://eurovelo3.fr/services?service=download-gpx&rid=1) from Namur (Belgium) to Tours (France). The rest of the route, between Tours and Irun (Spain), is to be published this summer -- at least that's what said Brunaud Devillard on behalf of *CycloTransEurope* when I wrote to inform them about [my future trip]({% post_url 2016-01-01-the-pilgrims-route %}).

In this post, I will show how to download the [`GPX`](https://en.wikipedia.org/wiki/GPS_Exchange_Format) track and convert it to [`geoJSON`](http://geojson.org) with {% include logo.md what='r' %}. I suppose that you have a good command of programation in general, and that you have had an introduction to *R*. There are basicly 2 options, depending on if you have the [`gdal`](http://www.gdal.org/) library installed on your computer or not<label for="sn-leaflet" class="sidenote-number"></label><input type="checkbox" id="sn-leaflet"/><span class='sidenote'>On *Linux*, you can easily install it with *Synaptic* whereas on *Mac*, I would recommand using [*Homebrew*](https://brew.sh){: .discreet}. I have no idea how to install `gdal` on a Windows computer.</span>. The `gdal` library provides a wide range of drivers for reading and writing spatial data.

<strong>Method 1. </strong>Quite transparently, the `rgdal` package is an interface with `gdal`. The exact list of all available drivers is given within *R* by `ogrDrivers()`. In case the `GPX` was not included in the list, please see the alternative solution.

<aside class='remark'><p markdown='1'>The handling of spatial objects in *R* requires the `sp` package. However, its use can be tricky. For a extensive overview of the `sp` package and to geographical information in *R*, see [this presentation of Roger Bivand](http://geostat-course.org/system/files/monday_slides.pdf). The most common tasks also requires [`rgdal`](https://cran.r-project.org/web/packages/rgdal/index.html) for reading, writing and converting between different formats and [`rgeos`](https://cran.r-project.org/web/packages/rgeos/index.html) for common operations such as intersection, simplification, area computation, etc.</p></aside>

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

Now, the file can be rendered seamlessly with {% include logo.md what='leaflet' %} onto a map.

<div class='wide'>
  <div id='map'></div>
</div>

**Method 2.** The other solution takes advantage of the very definition of the [`GPX`](https://en.wikipedia.org/wiki/GPS_Exchange_Format) format, which is just a variety of [`XML`](http://www.w3schools.com/xml). We can thus use the [`xml2`](https://github.com/hadley/xml2) package for reading the file, and then build a spatial object from scratch with the `sp` package.

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

<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('map', {
    minZoom: 4,
    touchZoom: false,
    scrollWheelZoom: false,
    center: [49, 3],
    zoom: 6
  })
  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
attribution: 'Tiles &copy; Esri'}).addTo(map);

  // $.getJSON("/data/2016-05-17-ev3.geojson", function(data) {
  //   console.log(data);
  //   L.geoJson(data).addTo(map);
  // });

  $.getJSON("/data/2016-05-17-how-to-convert-gpx-to-geojson-with-r/namur-tours.geojson", function(data) {
    console.log(data);
    L.geoJson(data).addTo(map);
  });

 </script>