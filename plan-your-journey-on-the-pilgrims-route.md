---
layout: default
title:  eurovelo
---

<main id='project-container'>
  <!--<div class="ribbon-wrapper">
    <div class="ribbon">UNDER CONSTRUCTION</div>
  </div>-->
  <section id='left-column'>
    <h1>A planner for The Pilgrims' Route</h1>
    <p>Let’s imagine you have collected, one way or another, the GPS file for your trip on The Pilgrims' Route. Do you thing you are done with planning? Of course not: you need a tool to read and use the track. And it is not as easy at it seems to read a track of more than 5000 km. And even less convenient to contrast it to other source of information such as list of hotels, campings, restaurants, supermarkets… that you will use by hundreds.</p>
    <p markdown='1'>This website -- in construction -- is here to help. For now, you will only find the GPS track and this interactive map. But many features are coming.</p>
    <a href="/data/biroto-ev3.gpx"><button class="btn btn-default btn-primary">DOWNLOAD GPS TRACK</button></a>
    <p markdown='1'>In the meanwhile, if you are interested by all the technique happening behind the scene, you are welcome to visits [*The Making of*](/blogs/journey-planner-the-making-of).</p>
    <footer markdown='1'>Font [*Handwriting Draft*](http://fontscafe.com/font/handwriting-draft-font){: .discreet} &copy; [*fontscafe.com*](http://fontscafe.com). Track created by the *OpenStreetMap* community and [*Biroto*](http://www.biroto.eu/en/cycle-route/europe/eurovelo-pilgrims-route-ev3/rt00000408) under [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0){: .discreet} and rendered on the map with {% include logo.md what='leaflet' %}. Tiles &copy; Esri.
</footer>
  </section>
</main>

<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('project-container', {
    minZoom: 4,
    center: [55, -10],
    zoom: 4,
    zoomControl: false,
  })
  
  L.control.zoom({position:'topright'}).addTo(map);

  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer(
    'http://server.arcgisonline.com/'+
    'ArcGIS/rest/services/World_Topo_Map/'+
    'MapServer/tile/{z}/{y}/{x}'
  ).addTo(map);

  $.getJSON("/data/2016-05-21-ev3.geojson", function(data) {
    L.geoJson(data).addTo(map);
  });

 </script>