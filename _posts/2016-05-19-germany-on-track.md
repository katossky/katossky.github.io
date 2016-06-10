---
layout:     post
title:      Germany on track
categories: [Journey Planner - The Making of]
tags:       [Radnetz, Eurovelo network, Eurovelo 3]
thumbnail:  /img/thumbnails/importing-the-german-gps-track.png
summary:    Radnetz Deutschland distributes for free the GPS tracks of its network. Why not take advantage of this for mapping route EuroVelo 3, alias Radnetz 7? Applying what we just learned, it is actually now just a question of minutes between when we download the file and when we display it on a map.
---

[Yesterday]({% post_url 2016-05-18-radnetz-deutschland %}), I discovered {% include logo.md what='dnetz' %}, the German national cycling network. Moreover, I discovered that *dnetz*'s [website](http://www.radnetz-deutschland.de/en.html) provides the GPS track of each route in the network. Last but not least, I learned that route {% include logo.md what='d7' %} is actually the *EuroVelo* route {% include logo.md what='ev3' %}.

*EuroVelo 3*, doesn't it ring a bell? Yes, indeed! It's [*The Pilgrims' Route*]({% post_url 2016-01-01-the-pilgrims-route %}), the bike route of over 5000 km running from Trondheim (Norway) south to Santiago-de-Compostella (Spain) that [I will ride this summer]({% post_url 2016-01-01-the-pilgrims-route %}). Maybe you also remember [my project]({% post_url 2016-01-20-a-planner-for-the-pilgrims-route %}) to make a journey planning service for this route.

So, why not take advantage of *dnetz*'s GPS tracks for mapping *EuroVelo* 3? We can even compare them with [the data from *OpenStreetMap*]({% post_url 2016-04-22-how-to-download-data-from-openstreetmap %})!

## Quickly built...

The track of route {% include logo.md what='d7' %} is available [here](http://www.radnetz-deutschland.de/index.php?eID=tx_nawsecuredl&u=0&file=fileadmin/Redaktion/Dateien/D-Route_7/Tracks/D-Route7.gpx&t=1463668847&hash=8937aaabac1003afcde14b04a65162cdf25eea22) in format {% include logo.md what='gpx' %} and, applying [what we learned the other day]({% post_url 2016-05-17-how-to-convert-gpx-to-geojson-with-r %}), it is now just a question of minutes between when we download the file and when we display it on a map.

<div class='wide'>
  <div id='map' class='high'></div>
  <p class='legend' markdown='1'>**Even and uneven lines.** When the data is imported as only one track -- as here with the GPS track from *dnetz*, the display is even, with one plain, smooth line. This is in contrast with imports from *OpenStreetMap*, which are made of several hundreds of smaller tracks, hence the unhomogeneous rendering.</p>
</div>

## ... and quickly analysed

The first and happy result is that data from *dnetz* (in blue) are complete, with one consistent and continuous line from Flensburg to Aachen. This is to oppose to the track from *OpenStreetMap*, which is completely irregular, with many line breaks causing an ugly rendering on the map<label for="sn-leaflet" class="sidenote-number"></label><input type="checkbox" id="sn-leaflet"/><span class='sidenote'>I use the `JavaScript` library {% include logo.md what='leaflet' %} for the construction of the map. I will explain how it works an other day but you can already have a look at [this intoductive exemple](http://leafletjs.com){: .discreet} on *Leaflet*'s website.</span>.

The second (and less happy) result is that the two tracks surprisingly disagree on non-negligeable parts of the itinerary, for instance at the arrival to Hambburg.

Maybe there are good reasons for these differences -- such as agricultural roads that ceased to be correctly maintained -- but I do not have yet any information for favoring one track over the other. In the meanwhile, I will favor route {% include logo.md what='d7' %}, for the only and wrong reason that the rendering on the map is smoother.

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

  var dnetz = new L.layerGroup();
  $.getJSON("/data/2016-05-19-germany-on-track/dnetz.geojson", function(data) {
    L.geoJson(data, {
      style: function (feature) {
        return {color: '#377eb8'};
      },
      onEachFeature: function (feature, layer) {
        dnetz.addLayer(layer);
      }
    });
  });
  dnetz.addTo(map);
  
  var osm = new L.layerGroup();
  $.getJSON("/data/2016-05-19-germany-on-track/osm.geojson", function(data) {
    L.geoJson(data, {
      style: function (feature) {
        return {color: '#FFA500'};
      },
      onEachFeature: function (feature, layer) {
        osm.addLayer(layer);
      }
    });
  });
  osm.addTo(map);

  L.control.layers({}, {
    "<span id='blue-line'></span> Route D7 from <em>Radnetz Deutschland</em>": dnetz,
    "<span id='orange-line'></span> Route EV3 from <em>OpenStreetMap</em>":      osm
  }, {collapsed: false}).addTo(map);

 </script>
