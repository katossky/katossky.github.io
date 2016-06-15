---
layout:        default
title:         eurovelo
redirect_from: /plan-your-journey-on-the-pilgrims-route
---

<main id='project-container'>
  <!--<div class="ribbon-wrapper">
    <div class="ribbon">UNDER CONSTRUCTION</div>
  </div>-->
  <section id='left-column'>
    <h1>A planner for The Pilgrims' Route</h1>
    <p>For sure you know how cumbersome it is to plan a longdistance trip when there exists no map of you itinerary. Even if you miraculously find the GPS track for it, how are you going to even <em>read</em> a route of more than 1000&nbsp;km? How will you contrast it to other source of information such as list of hotels, campings, restaurants, supermarkets… that you will use by hundreds?</p>
    <p markdown='1'>This website -- in construction -- is here to help. For now, you will only find the GPS track and this interactive map. But many features are coming.</p>
    <a href="/data/biroto-ev3.gpx"><button class="btn btn-default btn-primary">DOWNLOAD TRACK</button></a>
    <p markdown='1'>In the meanwhile, if you are interested by all the technique happening behind the scene, you are welcome to visits [*The Making of*](/blogs/journey-planner-the-making-of).</p>
    <footer markdown='1'>Font [*Handwriting Draft*](http://fontscafe.com/font/handwriting-draft-font){: .discreet} &copy; [*fontscafe.com*](http://fontscafe.com){: .discreet}. Track created by the *OpenStreetMap* community and [*Biroto*](http://www.biroto.eu/en/cycle-route/europe/eurovelo-pilgrims-route-ev3/rt00000408){: .discreet} under [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0){: .discreet} and rendered on the map with [*Leaflet*](leafletjs.com){: .discreet}. Tiles &copy; Esri.
</footer>
  </section>
  <section id='controls'>
    <div id='counter'><span class='odometer'>0</span> kilometers</div>
  </section>
</main>

<script>
    
  // SETTING ---------------------------------------------------------------

  od = new Odometer({
    el: document.querySelector('#counter > span'),
    format: '(,ddd)'
  });

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
    layer.on('click', function(e){
      od.update(turf.lineDistance(data.features[0]));
    });
  });

 </script>
