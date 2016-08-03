---
layout:        default
title:         eurovelo
redirect_from: /plan-your-journey-on-the-pilgrims-route
cities:
  - name: Trondheim
    lat:  63.435909
    lon:  10.399766
  - name: Oslo
    lat:  59.923732
    lon:  10.751464
  - name: Gothenburg / Göteborg
    lat:  57.711642
    lon:  11.974851
  - name: Aalborg
    lat:  57.046895
    lon:   9.923305
  - name: Viborg
    lat:  56.450331 
    lon:   9.409383
  - name: Flensburg
    lat:  54.782562
    lon:   9.435985
  - name: Hamburg / Hambourg
    lat:  53.553222
    lon:   9.992550
  - name: Bremen / Brême
    lat:  53.075273
    lon:   8.808247
  - name: Osnabrück
    lat:  52.277730
    lon:   8.042510
  - name: Münster
    lat:  51.961084
    lon:   7.628638
  - name: Duisburg
    lat:  51.433012
    lon:   6.768285
  - name: Düsseldorf
    lat:  51.227193
    lon:   6.773530
  - name: Cologne / Köln
    lat:  50.940993
    lon:   6.956650
  - name: Bonn
    lat:  50.734857
    lon:   7.099188
  - name: Aachen / Aix-la-C.
    lat:  50.775529
    lon:   6.084543
  - name: Liège / Liege
    lat:  50.639904
    lon:   5.571193
  - name: Namur
    lat:  50.463514
    lon:   4.867042
  - name: Charleroi
    lat:  50.411461
    lon:   4.444688
  - name: Compiègne
    lat:  49.416998
    lon:   2.825630
  - name: Paris
    lat:  48.853332
    lon:   2.348392
  - name: Orléans
    lat:  47.899325
    lon:   1.910415
  - name: Tours
    lat:  47.396519
    lon:   0.686666
  - name: Angoulême
    lat:  45.648457
    lon:   0.156883
  - name: Bordeaux
    lat:  44.841071
    lon:  -0.574341
  - name: Pamplona / Pampelune
    lat:  42.815131
    lon:  -1.639551
  - name: Burgos
    lat:  42.340370
    lon:  -3.703867
  - name: León
    lat:  42.598258
    lon:  -5.566485
  - name: Santiago / St-Jacques
    lat:  42.878627
    lon:  -8.544856
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
    <!--<div class="input-group">
      <span class="input-group-addon"><span>In</span></span>
      <input name="days" id="days" type="text" class="form-control" placeholder="1, 12, 20...">
      <span class="input-group-addon">days</span>
    </div>-->
    <div class="input-group">
      <span class="input-group-addon"><span>At</span></span>
      <select class="form-control" id="speed">
        <option value=   ''>   </option>
        <option value= '60'> 60</option>
        <option value= '70'> 70</option>
        <option value= '80'> 80</option>
        <option value= '90'> 90</option>
        <option value='100'>100</option>
      </select>
      <span class="input-group-addon">km/day in average</span>
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

  var cities = {{ page.cities | map: 'name' | jsonify }};
  var lats   = {{ page.cities | map: 'lat'  | jsonify }};
  var lons   = {{ page.cities | map: 'lon'  | jsonify }};
  
  L.control.zoom({position:'bottomright'}).addTo(map);

  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer(
    'http://server.arcgisonline.com/'+
    'ArcGIS/rest/services/World_Topo_Map/'+
    'MapServer/tile/{z}/{y}/{x}'
  ).addTo(map);

  var temp = L.circleMarker(
    [lats[0], lons[0]],
    {color: 'grey'}
  );
  var from = L.circleMarker(
    [lats[0], lons[0]],
    {color: 'green'}
  );
  var to = L.circleMarker(
    [lats[lats.length-1], lons[lats.length-1]],
    {color: 'red'}
  );

  $.getJSON("/data/2016-05-21-ev3.geojson", function(data) {

    var the_pilgrims_route = new L.geoJson(data, {
      opacity: 0.6,
      weight:  3.5
    });
    the_pilgrims_route = the_pilgrims_route.getLayers()[0];
    
    var itinerary = jQuery.extend(true, {}, the_pilgrims_route );
    itinerary.addTo(map);

    var slice_itinerary = function(){
      var new_itinerary_geojson = turf.lineSlice(
        from.toGeoJSON(),
        to.toGeoJSON(),
        the_pilgrims_route.toGeoJSON()
      );
      var new_itinerary_coords = new_itinerary_geojson
        .geometry
        .coordinates
        .map(function(e){return L.latLng(e) });
      map.removeLayer(itinerary);
      itinerary = L.geoJson(new_itinerary_geojson, {
        opacity: 0.6,
        weight:  3.5
      }).getLayers()[0];
      itinerary.addTo(map);
      compute_stages();
      map.flyToBounds(itinerary.getBounds());
    }

    var stages         = new L.layerGroup();

    var compute_stages = function(){
      if(map.hasLayer('stages')){
        map.removeLayer(stages);
      }
      stages.clearLayers();
      var speed            = $('#speed').val();
      if(speed != ''){
        speed              = speed*1;
        var itinerary_json = itinerary.toGeoJSON();
        var distance       = turf.lineDistance(itinerary_json);
        var number_of_days = Math.ceil(distance / speed);
        var dayly_distance = distance / number_of_days;
        for(i=1; i<number_of_days; i++){
          var stage = turf.along(
            itinerary_json,
            i*dayly_distance,
            'kilometers'
          );
          var stage_coord = stage.geometry.coordinates.reverse();
          stages.addLayer(L.marker(
            stage_coord, {
              stroke:      false,
              fillOpacity: 1,
              radius:      5,
              icon:        L.divIcon({
                className: 'stage',   // Set class for CSS styling
                html:      '<span>'+i+'</span>'
              })
            }
          ));
        }
        stages.addTo(map);
      }
    }

    from       .on('add',    slice_itinerary);
    to         .on('add',    slice_itinerary);
    $('#speed').on('change', compute_stages);
    
  });

  // $.getJSON("/data/journey-planner/2016-06-20-michelin-restaurants.geojson", function(data){

  //   var michelin_restaurants = new L.geoJson(data);

  //   map.on('zoomend', function(e){
  //     if(map.getZoom() >= 7 && !map.hasLayer(michelin_restaurants)){
  //       michelin_restaurants.addTo(map);
  //     } else if (map.getZoom() < 7 && map.hasLayer(michelin_restaurants)) {
  //       map.removeLayer(michelin_restaurants);
  //     }
  //   });
  // });

  var star_layers = {};

  $.getJSON("/data/journey-planner/2016-06-20-michelin-restaurants.geojson", function(data) {
    console.log(data);

    L.geoJson(data, {
      onEachFeature: function (feature, layer) {
        var star_number = feature.properties.stars;
        if(star_number in star_layers){
          star_layers[star_number].addLayer(layer);
        } else {
          star_layers[star_number] = new L.layerGroup();
          star_layers[star_number].addLayer(layer);
        }
      }
    });

    map.on('zoomend', function(e){
      if(map.getZoom() >= 7 && !map.hasLayer(star_layers[3])){
        star_layers[3].addTo(map);
      }
      if(map.getZoom() >= 9 && !map.hasLayer(star_layers[2])){
        star_layers[2].addTo(map);
      }
      if(map.getZoom() >= 10 && !map.hasLayer(star_layers[1])){
        star_layers[1].addTo(map);
      }
      if(map.getZoom() >= 11 && !map.hasLayer(star_layers[0])){
        star_layers[0].addTo(map);
      }
      if(map.getZoom() < 7 && map.hasLayer(star_layers[3])){
        map.removeLayer(star_layers[3]);
      }
      if(map.getZoom() < 9 && map.hasLayer(star_layers[2])){
        map.removeLayer(star_layers[2]);
      }
      if(map.getZoom() < 10 && map.hasLayer(star_layers[1])){
        map.removeLayer(star_layers[1]);
      }
      if(map.getZoom() < 11 && map.hasLayer(star_layers[0])){
        map.removeLayer(star_layers[0]);
      }
    });

    // for(relation in relations){
    //   relations[relation].addTo(map);
    // }

  });

  $( "#querry-from" ).autocomplete({
    source: cities,
    focus: function( event, ui ) {
      //console.log(ui);
      for (i = 0; i < cities.length; i++){
        if(ui.item.value==cities[i]){
          map.removeLayer(temp);
          temp.setLatLng([lats[i], lons[i]]).addTo(map);
        }
      }
    },
    select: function( event, ui ){
      map.removeLayer(temp);
      if(map.hasLayer(from)){map.removeLayer(from);}
      for (i = 0; i < cities.length; i++){
        if(ui.item.value==cities[i]){
          from.setLatLng([lats[i], lons[i]]).addTo(map);
        }
      }
    }
  });

  $( "#querry-to" ).autocomplete({
    source: cities,
    focus: function( event, ui ) {
      //console.log(ui);
      for (i = 0; i < cities.length; i++){
        if(ui.item.value==cities[i]){
          map.removeLayer(temp);
          temp.setLatLng([lats[i], lons[i]]).addTo(map);
        }
      }
    },
    select: function( event, ui ){
      map.removeLayer(temp);
      if(map.hasLayer(to)){map.removeLayer(to);}
      for (i = 0; i < cities.length; i++){
        if(ui.item.value==cities[i]){
          to.setLatLng([lats[i], lons[i]]).addTo(map);
        }
      }
    }
  });

 </script>
