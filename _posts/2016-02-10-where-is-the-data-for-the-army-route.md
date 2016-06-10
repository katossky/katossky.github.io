---
layout:     post
title:      Where is the data for "The Army Route"?
categories: [Journey Planner - The Making of]
tags:       [Eurovelo, itinerary, Vejdirektoratet, Cyclistic, Hærvejen]
thumbnail:  /img/thumbnails/itinirary-data.png
---

<aside>
  <img src="/img/2016-06-07-povlsbro.jpg">
  <p class='legend' markdown='1'>**The bridge *Povlsbro* on *Hærevejen*, "The Army Road".** *The Pilgrims' Route* sometimes changes name when it enters one or another country. [*Hærvejen*](https://en.wikipedia.org/wiki/H%C3%A6rvejen){: .discreet} is the modern name of the ancient route running from [Viborg](https://en.wikipedia.org/wiki/Viborg,_Denmark){: .discreet} to [Hamburg](https://en.wikipedia.org/wiki/Hamburg){: .discreet} via [Flensburg](https://en.wikipedia.org/wiki/Flensburg){: .discreet} accross [Jutland](https://en.wikipedia.org/wiki/Jutland){: .discreet}, [Schleswig](https://en.wikipedia.org/wiki/Duchy_of_Schleswig){: .discreet} and [Holstein](https://en.wikipedia.org/wiki/Holstein){: .discreet}. The first occurence of this name dates back from a XVII<sup>th</sup> century map of Schleswig. The route has had many names, such as *Oksevejen* (The Oxes' Route), *Sakservejen* (The Saxons' Route), *Gammel Viborgvej* (The Old Viborg Route), *Studevejen* (The Cattle Route), *Adelvejen* (The Noblemen's Route) and of course ***Pilgrimvejen***: **The Pilgrims' Route**.</p>
  <p class='source' markdown='1'>*Adapted from [English](https://en.wikipedia.org/wiki/H%C3%A6rvejen) and [Danish Wikipedia](https://da.wikipedia.org/wiki/H%C3%A6rvejen), my translation. Photo by [Jørgen Rasmussen](https://da.wikipedia.org/wiki/Fil:Povlsbro_east_20040424.jpg){: .discreet}.*</p>
</aside>

I recently decided [to start developping a website]({% post_url 2016-01-20-a-planner-for-the-pilgrims-route %}) that will help cyclists to plan their long-distance trips on the *EuroVelo* network. In order to diminish the burden of the development, I first focus on the route [I will ride this summer]({% post_url 2016-01-01-the-pilgrims-route %}), namely *The Pilgrims' Route*, *EuroVelo* route number {% include logo.md what='ev3' %}. As you can imagine, the cornerstone of such a project is data of good enough quality for the itinerary. **In this post, I will illustrate the not-so-easy quest for geographical data.**

## The constraints.

1. I cannot collect / create the track myself, since it would not be generalisable to the full *EuroVelo* network, unless I spend the next 5 years on the road and thousands of hours behind the computer. I can however marginnally edit the sources.
2. By "geographical data", I mean anything convertible to a [polygonal line](https://en.wikipedia.org/wiki/Polygonal_chain). Most of the time, this will be GPS data in the {% include logo.md what='gpx' %} format.
3. Even though this should be obviously their role, the *EuroVelo* network does not collect nor provide the data about the network. The task would have been otherwise very simple. When contacted, the *EuroVelo* chat officer passes off the responsability to the national authorities in charge of the network.
4. In order to keep the post short enough, I will focus on Denmark only, but the same problem of multiple, non compatible sources are encountered in other countries, sometimes in an exarcebated way, like in Germany, where the many *länder* are each responsible locally for the bike infrastructure.

## The quest - Part 1

Starting from [the *EuroVelo* website](http://www.eurovelo.com) we are first redirected to [Cyclistic](http://cyclistic.dk), an itinirary planner that does not seem to be working currently, and to [*haervej.com*](http://www.haervej.com), the official Danish website for *The Pilgrims' Route*. Indeed for some reason when entering Denmark, the *Pilgrims' Route* suddenly changes its name for *Hærvejen*, "The Army Road". *Comprenne qui pourra!*

[Cyclistic](http://cyclistic.dk) has a page [dedicated to *Hærvejen*](http://cyclistic.dk/en/official-routes/show-route/?routeId=1497) but this is not helpful since the website is out of order. On its side, [*haervej.com*](ttp://www.haervej.com) points to [the account](http://www.gpsies.com/mapUser.do?username=VisitViborg) of [*VisitViborg*](http://www.visitviborg.dk) on [*GPSies*](http://www.gpsies.com), where we can download the track of *The Pilgrims' Route* in three segments, in the formats {% include logo.md what='gpx' %}, `KML` or `KMZ`. Here is our first data source.

<div class='wide'>
  <a href="http://kort.haervej.dk/index.php"><img src="/img/screenshots/2016-06-07-screenshot-kort-haervej-dk.png" class='screenshot'></a>
  <p class='legend' markdown='1'>[**kort.haervej.dk**](http://kort.haervej.dk/index.php){: .very-discreet} is rich map, but not terribly user-friendly. Very rich indeed: only for accomodation, one has the choice between 8 possibilities, from the most luxuous (hotels) to the most rustic (shelters). The map, however, quickly disappears under a chaos of symbols.</p>
</div>

[*haervej.com*](ttp://www.haervej.com) also points toward [an interactive map](http://kort.haervej.dk/index.php), which unfortunately does not provide any information about sources. But an inspection of the page reveals that the cycle track in the `KML` format is served on demand by the following URL: `http://kort.haervej.dk/index.php/en/?option=com_geocontent&task=layers.kml&typename=23`. And here is a second data source.

[*Vejdirektoratet*](http://vejdirektoratet.dk), the Danish agency for road maintenance, also provides [a map of national cycle tracks](http://trafikkort.vejdirektoratet.dk/index.html?usertype=3), one of which is "*Hærvejsruten*". When contacted about their sources, they reply that they rely on [*OpenStreetMap*](http://www.openstreetmap.org)<label for="sn-osm" class="sidenote-number"></label><input type="checkbox" id="sn-osm"/><span class='sidenote'>[*OpenStreetMap*](http://www.openstreetmap.org) is an open-source equivalent to *Google Map*: the map is buildt collectively, and anyone can modify it. Click [here](http://learnosm.org/en) for an introduction.</span>.

To finish with, <a href="http://kortforsyningen.dk"><em>Kortforsyningen</em></a>, the Danish national agency for geographical information, surprisingly does not seem to provide any information about national (or local) cycle routes.

## The quest - Part 2

I must confess that I discorvered the two last sources of data once I had stopped investigating the Danish case and on the contrary generalized my quest to the whole track of *The Pilgrims' Route* accross Europe.

The first source is the already mentionned [*OpenStreetMap*](http://www.openstreetmap.org). The [full route](http://www.openstreetmap.org/relation/299546) and [the Danish section](http://www.openstreetmap.org/relation/1911568) are independantly available. Compared to the other sources, [*OpenStreetMap*](http://www.openstreetmap.org) has the advantage of being world-wide, constantly updated, vastly documented, and to potentially contain all the other *EuroVelo* routes. On the other hand, data consistency is the responsibility of each and every single mapper, and in pracice, the route can be interupted on some segments or, on the contrary, present competing itiniraries. Furthermore, downloading data from *OpenStreetMap* is not as easy as you may think<label for="sn-overpass" class="sidenote-number"></label><input type="checkbox" id="sn-overpass"/><span class='sidenote'>In [this post]({% post_url 2016-04-22-how-to-download-data-from-openstreetmap%}), I explain how to export data from *OpenStreetMap* through the *Overpass API*. And discuss more in details the advantages and drawbacks of using *OpenStreetMap*.</span>. *OpenStreetMap* counts as our third source.

Last but not least, I randomly encountered [*Biroto*](http://www.biroto.eu), a website explictily oriented towards multi-days bike trip -- put in an other way: [a competitor]({% post_url 2016-01-20-a-planner-for-the-pilgrims-route %}). *Biroto* collected and consolidated many different data sources<label for="sn-biroto-sources" class="sidenote-number"></label><input type="checkbox" id="sn-biroto-sources"/><span class='sidenote'>For Denmark, the source given by *Biroto* is a "*hærvejsruten*". I then suppose it is the data from *Vejdirektoratet*.</span> and then published the complete track of *The Pilgrims' Route* as [one unique file](http://www.biroto.eu/en/cycle-route/europe/eurovelo-pilgrims-route-ev3/rt00000408) in {% include logo.md what='gpx' %} format. They are furthermore kind enough to distribute it under a [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/){: .discreet} licence. This is the fourth and last data source.

## The results

The following interactive map displays the competing 4 sources. As we may have expected, the two sources extracted from [*haervej.com*](http://www.haervej.com) -- the one from *GPSies* and the one from *kort.harvej.dk* -- exactly coincide. The two others only marginally differ, like here in the center of Frederikshavn.

<div id='map' class='wide high'></div>

<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('map', {
    minZoom: 4,
    touchZoom: false,
    scrollWheelZoom: false,
    center: [57.435, 10.54],
    zoom: 14
  })
  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles &copy; Esri'
  }).addTo(map);

  var addMyLayer = function(file, color){
  	var myLayer = new L.layerGroup();
  	$.getJSON(
      '/data/2016-02-10-where-is-the-data-for-the-army-route/' + file,
      function(data) {
      	L.geoJson(data, {
  	      style: function (feature) {
  	        return {color: color};
  	      },
  	      onEachFeature: function (feature, layer) {
  	        myLayer.addLayer(layer);
  	      }
  	    }
      );
    });
    myLayer.addTo(map);
  	return myLayer;
  }

  L.control.layers({}, {
    "<span id='red-line'></span> GPSies":          addMyLayer('gpsies.geojson',          '#e41a1c'),
  	"<span id='blue-line'></span> kort.haervej.dk": addMyLayer('kort.haervej.dk.geojson', '#377eb8'),
    "<span id='green-line'></span> OpenStreetMap":   addMyLayer('osm.geojson',             '#4daf4a'),
    "<span id='purple-line'></span> Biroto":          addMyLayer('biroto.geojson',          '#984ea3')
  }, {collapsed: false}).addTo(map);

 </script>