---
layout:        default
title:         eurovelo
redirect_from: /plan-your-journey-on-the-pilgrims-route
---

<main id='project-container'>

</main>

<script>
    
  // SETTING ---------------------------------------------------------------

  var map = L.map('project-container', {
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
