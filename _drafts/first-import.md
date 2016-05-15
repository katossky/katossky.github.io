---
layout:     page
title:      The track - importation
categories: [Eurovelo 3 - The making of]
tags:       [leaflet.js, OverPass API, regular expressions, OSM relations, OpenStreetMap]
thumbnail:  
summary:    The tracks of Eurovelo 3 as they exist on OpenStreetMap
---

Today is **the** day: the day where my <a href="">Eurovelo 3 project</a> comes to life. I just downoloaded all available data aout the route from OpenStreetMap, cleaned it, and published it. From now on, I will "just" have to edit data on OpenStreetMap and reimport the data for the map to be automatically updated.

I've already talked about <a href="">how to import data from OpenStreetMap</a>. But now, the problem is not only to plot the raw data, but to filter them and publish them in a beautiful way.

First step, downloading all available data. In <a href="">my latest post on the subject</a>, we realised that looking in OpenStreetMap's database for all objects containing the keyword "Eurovelo 3" leads:

- to missing some tracks listed with other keywords, such the part of the route between Oslo and Gothenburg, recorded as part of Eurovelo 12 rather than Eurovelo 3 ;
- to fetching undesired results, such a duplicate itinirary in Danmark.

Both issues have to be confronted on an *ad hoc* basis, by manually editting the list of objects (or "relations" in OpenStreetMap's dialect) returned by a simple request. On <a href="http://overpass-turbo.eu">Overpass Turbo</a>, the request:

    relation[name~"[Ee](uro)?[Vv](elo)? ?3"];
    out tags;

.. returns 14 relations, only 3 of which correspond to an actual portion of the Eurovelo 3 route: in Norway (relation n°`2797378`), Denmark (`1911568`) and Germany (`2795128`).

On the other hand, completing the route when data exists but is listed under different keywords requires one additional step, namely to visit <a href="">the Eurovelo website</a> and find out which parts of Eurovelo 3 are shared with other Eurovelo routes. There are actually 3 of them: Eurovelo 12 between Oslo (Norway) and Gothenburg (Sweden) ; Eurovelo 6 between Orléans (France) and Tours (France) ; Eurovelo 1 between Pamplona (Spain) and Burgos (Spain).

The requests:

    relation[name~"[Ee](uro)?[Vv](elo)? ?1[^0-9]"];
    out tags;

    relation[name~"[Ee](uro)?[Vv](elo)? ?6"];
    out tags;

    relation[name~"[Ee](uro)?[Vv](elo)? ?12"];
    out tags;

... reveal that Eurovelo 1 is registered solely in France and Norway (and thus not between Pamplona and Burgos); that Eurovelo 6 is recorded almost everywhere *but* between Orléans and Tours ; and that the route in Sweden is relation n°`1770999`.



<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('map', {
    minZoom: 3,
    touchZoom: false,
    scrollWheelZoom: false,
    center: [56, 12],
    zoom: 3
  })
  var relations = {};

  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}'
  ).addTo(map);

  $.getJSON("/data/2016-04-22-overpass-API-filtered.geojson", function(data) {
    console.log(data);
    L.geoJson(data, {
      onEachFeature: function (feature, layer) {
        var relation = feature.properties['@relations'][0].rel;
        if(relation in relations){
          relations[relation].addLayer(layer);
        } else {
          relations[relation] = new L.layerGroup();
          relations[relation].addLayer(layer);
        }
      }
    });

    for(relation in relations){
      relations[relation].addTo(map);
    }

    L.control.layers({}, relations, {collapsed: false}).addTo(map);

  });
 </script>