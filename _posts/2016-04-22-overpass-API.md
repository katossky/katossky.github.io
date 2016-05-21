---
layout:     post
title:      The Overpass API
categories: [Eurovelo 3 - The making of]
tags:       [leaflet.js, OverPass API, regular expressions, OSM relations, OpenStreetMap]
thumbnail:  /img/thumbnails/overpass-api-small.jpg
summary:    An exploration of OpenStreetMap's feature extraction tool
---

In the process of creating a website for Eurovelo 3, I wanted to automate the download of the itinirary data from Open Street Map, and the display on my own website. Unfortunately, this is not an easy task.

Indeed, OpenStreetMap have nice extraction features if you want to download a lot of (if not all) information about a small region. But it is really not adapted for retreiving narrow information over a wide region. And this is, sadly, my case: I want all the points (or "nodes", in the OpenStreetMap parlance) and lines ("ways"), over the whole Europe, that constitute the Eurovelo 3 itinirary.

OpenStreetMap's wiki however pointed me the right direction. Its "Downloading data" page (<a href="http://wiki.openstreetmap.org/wiki/Downloading_data">wiki</a>) lists all the possibilities for retreiving (un)filtered information. And in my case they advice the so-called Overpass API (<a href="http://wiki.openstreetmap.org/wiki/Overpass_API">wiki</a>).

I'll pass over the API language complexities (<a href="http://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide">wiki</a>). The only thing you have to know is that it is possible to get the list of all <em>nodes</em> and <em>ways</em> that constitute the Eurovelo 3 route with this request:

    relation[name~"[Ee](uro)?[Vv](elo)? ?3"];
    out tags;

 A "relation", for OpenStreetMap enthusiasts, is a collection of points (or "nodes"), lines (or "ways")... and other relations. Here, I request all relations whose name (`[name...]`) correspond to the given regular expression (`~"[Ee](uro)?[Vv]([eé]lo)? ?3"`). I won't go into the details of regular expressions now. One must only know that they are a powerful tool for matching character strings. The one I use can match "eurovelo 3" as well as "EuroVelo 3", "EV3" or "EVelo3". Eventually, I request that only the tags - and not, for instance, the coordinates - are returned, using the command `out tags;`.

 This returns a list of relations. Some of them are irrelevant, and result from a bad match with regular expressions. For instance, I match the Italian montain bike itinirary `PNEV3`. But most of them are relevant like relations 2797378 (Norway), 1911568 (Denmark) and 2795128 (Germany). The last ones are relavant since they are correctly on the route, but they form such a small part of it that they are virtually useless: relations 299546 in Denmark and 4291999, 4292056, 6117075 in France.

 <div id='map' class='wide'></div>

 But so far, I did not show how to retrieve the information needed to map those so-called relations. Actually, as I explained, a relation is just a collection of points and lines and, in our case, only of lines. If we want to map the route, we have to get access to the coordinates of each line making up the route. This is done on the Overpass API with the , and if we plant to plot them, we do not have any spatial information - which is however necessary for mapping them! I can get access the data throught this other request:

    relation(2797378);
    (._;>;);
    out;

This is much quicker that the first request. In the first request, Overpass had to scan all existing relations (they are .... at the moment) to find those that matched the specified condition whereas now, we directly give the identifier.

    (
      relation( 299546);
      relation(1911568);
      relation(2795128);
      relation(2797378);
      relation(4291999);
      relation(4292056);
      relation(6117075);
    );
    (._;>;);
    out body;

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
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles &copy'
  }).addTo(map);

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