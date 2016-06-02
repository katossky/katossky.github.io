---
layout:     post
title:      Importing the German GPS track
categories: [Journey Planner - The Making of]
tags:       [Radnetz, Eurovelo network, Eurovelo 3]
thumbnail:  /img/thumbnails/importing-the-german-gps-track.png
summary:    A comparison of the OpenStreetMap track with the one from Radnetz Deutschland.
---

Yesterday, I discovered ![*dnetz*](/img/logos/dnetz.png), the German national cycling network. Moreover, I discovered that <span style='display:inline-block'>![*dnetz*](/img/logos/dnetz.png)'s</span> [website](http://www.radnetz-deutschland.de/en.html) provides the GPS track of each route in the network. Last but not least, I learned that route ![D7](\img\logos\d7.png) is actually the {% include logo.md what="eurovelo" %} route ![EV3](\img\logos\ev3.png).

Eurovelo ![EV3](\img\logos\ev3.png), doesn't it ring a bell? Yes, indeed! It's *The Pilgrim way*, the bike route of over 5000 km running from Trondheim (Norway) south to Santiago-de-Compostella (Spain) that [I will ride this summer](). Maybe you also remember that my whole [Eurovelo 3 project](/eurovelo) is about making a planning service for this route. And if you've followed the previous episodes, you know that the data I extracted from OpenStreetMap for mapping out the intinerary [is not of first quality](first-importation)... So, why not take advantage of [*Radnetz*'s GPS track](http://www.radnetz-deutschland.de/index.php?eID=tx_nawsecuredl&u=0&file=fileadmin/Redaktion/Dateien/D-Route_7/Tracks/D-Route7.gpx&t=1463668847&hash=8937aaabac1003afcde14b04a65162cdf25eea22) for mapping Eurovelo 3?

Applying [what we just learned the other day](importing-the-namur-tours-gps-track), it is actually now just a question of minutes between when we download a `gpx` file and when we display it on a map. The original track from OpenStreetMap (in blue) is given for comparison:

<div id='map' class='wide high'></div>

The first (and happy) result is that data from ![*dnetz*](/img/logos/dnetz.png) (in orange) are complete, with one consistent and continuous line from Flensburg to Aachen. This is to oppose to the tracks from OpenStreetMap, which [we've seen to be](first-importation-of-the-track) completely irregular, with many line breaks causing an ugly rendering with <img src="/img/logos/leaflet.png">.

The second (and less happy) result is that the two tracks surprisingly disagree on non-negligeable parts of the itinerary. A good exemple is the arrival to Hambburg.

<div><img src="/img/screenshots/2016-05-18-d7-ev3-disagree-near-hamburg.jpg" class='screenshot'></div>

Maybe there are good reasons for these differences, such as agricultural roads that ceased to be correctly maintained -- but I do not have any information for favoring one track over the other. I will soon send a mail to ![*dnetz*](/img/logos/dnetz.png) and ask. In the meanwhile, I will favor the ![D7](\img\logos\d7.png), for the only and wrong reason that the rendering on the map is smoother.

<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('map', {
    minZoom: 4,
    touchZoom: false,
    scrollWheelZoom: false,
    center: [53, 7],
    zoom: 6
  })
  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
attribution: 'Tiles &copy; Esri'}).addTo(map);

  var d7_from_radnetz = new L.layerGroup();
  $.getJSON("/data/2016-05-18-germany.geojson", function(data) {
    L.geoJson(data, {
      style: function (feature) {
        return {color: '#FFA500'};
      },
      onEachFeature: function (feature, layer) {
        d7_from_radnetz.addLayer(layer);
      }
    });
  });
  d7_from_radnetz.addTo(map);
  
  var ev3_from_openstreetmap = new L.layerGroup();
  $.getJSON("/data/2016-05-18-ev3-osm.geojson", function(data) {
    L.geoJson(data, {
      onEachFeature: function (feature, layer) {
        ev3_from_openstreetmap.addLayer(layer);
      }
    });
  });
  ev3_from_openstreetmap.addTo(map);

  L.control.layers({}, {
    "Route D7 from Radnetz":        d7_from_radnetz,
    "Route EV3 from OpenStreetMap": ev3_from_openstreetmap
  }, {collapsed: false}).addTo(map);

 </script>
