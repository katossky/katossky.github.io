---
layout:        default
title:         eurovelo
redirect_from: /plan-your-journey-on-the-pilgrims-route
---

<header id='project-header'>
  <ul>
    <li></li>
    <li></li>
    <li></li>
  </ul>
</header>

<main id='project-container'>
  <div id='querry-pannel'>
    <h1>A Planner for The Pilgrims' Route</h1>
    <div class="input-group">
      <span class="input-group-addon"><span>From</span></span>
      <input name="querry-from" id="querry-from" type="text" class="form-control" placeholder="Trondheim, Oslo...">
    </div>
    <div class="input-group">
      <span class="input-group-addon"><span>To</span></span>
      <input name="querry-to" id="querry-to" type="text" class="form-control" placeholder="Santiago, Bordeaux...">
    </div>
    <div class="input-group">
      <span class="input-group-addon"><span>In</span></span>
      <input name="days" id="days" type="text" class="form-control" placeholder="1, 12, 20...">
      <span class="input-group-addon">days</span>
    </div>
  </div>
  <div id='map-pannel'></div>
  <div id='itinerary-pannel'></div>
</main>

<script>
    
  // SETTING ---------------------------------------------------------------

  var map = L.map('map-pannel', {
    minZoom: 4,
    center: [55, -10],
    zoom: 4,
    zoomControl: false,
  })
  
  L.control.zoom({position:'bottomright'}).addTo(map);

  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer(
    'http://server.arcgisonline.com/'+
    'ArcGIS/rest/services/World_Topo_Map/'+
    'MapServer/tile/{z}/{y}/{x}'
  ).addTo(map);
  
  $.getJSON("/data/2016-05-21-ev3.geojson", function(data) {
    var layer = L.geoJson(data);
    layer.addTo(map);
    //layer.on('click', function(e){
    //  od.update(turf.lineDistance(data.features[0]));
    //});
  });

 </script>
