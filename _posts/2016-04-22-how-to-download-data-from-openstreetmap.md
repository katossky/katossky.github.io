---
layout:     post
title:      How to download data from OpenStreetMap?
categories: [Journey Planner - The Making of]
tags:       [leaflet.js, OverPass API, regular expressions, OSM relations, OpenStreetMap]
thumbnail:  /img/thumbnails/overpass-api-small.jpg
subtitle:   Getting introduced to the Overpass API
summary:    ...
---

Maybe do you already know about my project of [building a bike journey planner]({% post_url 2016-01-20-a-planner-for-the-pilgrims-route %}) for the *EuroVelo* network? I am starting with route number 3, *The Pilgrims' Route*, since I will test it myself [this summer]({% post_url 2016-01-01-the-pilgrims-route %}). And the first thing to do is to collect data about the itinerary.

I have just discussed about the different sources for [the cycle track in Denmark]({% post_url 2016-02-10-where-is-the-data-for-the-army-route %}) and I mentionned that, compared to the other sources, *OpenStreetMap* has many advantages. *OpenStreetMap*? It is a sort of open-source *Google Map*, that anyone can modifify, and whose data is accessible to all. **But how do you access to *OpenStreetMap* data exactly?** It is actually not as simple as what I thought.

## Easy access to raw data

Let me contradict myself immediately. Extracting *all* the data available on a *small* zone is astonishingly simple: go on [*OpenStreetMap*](http://www.openstreetmap.org) ; navigate to the place you are interested in ; zoom until the city level (level 11) ; export. Damned simple, isn't it?

<div class='wide'><img src="/img/screenshots/2016-06-07-osm.gif" class='screenshot'></div>

Extracting *all* the data available of *predefined* region comes out quite handy too. You just connect to [*geofabrik.de*](http://download.geofabrik.de), navigate until the level of your choice<label for="sn-geofabrik-levels" class="sidenote-number"></label><input type="checkbox" id="sn-geofabrik-levels"/><span class='sidenote'>The main levels are *continent* and *country*. Some tailored zones exist, such *Alps* or *British Isles*.</span> ; chose your favorite format ; download. But maybe we do not *really* need 17&nbsp;Go of information for Europe.

Indeed, retreiving *specific* information -- say, all the traffic lights, all the fast-foods, all the trees, etc. -- over a *wide* region -- say, bigger than a city -- is much more difficult. And this is, sadly, my case: I want all the roads that form the *Pilgrims' Route* over Danmark, or even better, Europe. Luckily, *OpenStreetMap*'s wiki is rich. Its [*Downloading data*](http://wiki.openstreetmap.org/wiki/Downloading_data) page lists all the possibilities for retreiving (un)filtered information. And in my case they advice the so-called [*Overpass API*](http://wiki.openstreetmap.org/wiki/Overpass_API) and one of its interface, [*overpass turbo*](http://overpass-turbo.eu).

## Open Street Map basics

Let me skip the complexities of *OpenStreetMap* as well as of those of the language used inside the *Overpass API*<label for="sn-overpass-api" class="sidenote-number"></label><input type="checkbox" id="sn-overpass-api"/><span class='sidenote'>If you are interested however, you are welcome to dive in OpenStreetMap's [wiki](http://wiki.openstreetmap.org) or to have a look at [the *Overpass API* manual](http://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide).</span>. Instead, let me focus 2 minutes on what you *have to* know to understand the rest of this post. 

First, you must accept that it is not *so* easy to organise information. *OpenStreetMap* has chosen one way, out of many. In this scheme, a cycle route is an object made of several road section (or lines), and a line is in turn a set of points<label for="sn-lines" class="sidenote-number"></label><input type="checkbox" id="sn-lines"/><span class='sidenote'>If the line was straight, two points would be enough to describe it: the beginning and the end. But in the general case, each route section is somewhat curved, and the feeling of roundness is given by the association of many, tiny straight lines. A line is then usually made of a lot of points.</span>. But that would be too simple to call a spade a spade! In *OpenStreetMap*'s parlance, a point is called a *node*, a line a *way* and an object a *relation*.

Secondly, in *OpenStreetMap*'s scheme, each object, each line and each node has a unique number associated to them. It is done so for identifying exaclty what we are talking about. Cleverly, this number is called an *identifier*. In the data, it is shortenned to `id`.

The third thing you must realise is that a point (a node) can belong to several lines (ways) and that, in turn, an object (a relation) is often made of several lines and points. For instance, a country is a set of borders (ways/lines) plus a capital (node/point). It would be absurd -- and inefficient -- to copy the points as many times as they appear in different objects, and *OpenStreetMap* cleverly decided to store only the relationship between the items of different categories<label for="sn-storage" class="sidenote-number"></label><input type="checkbox" id="sn-storage"/><span class='sidenote'>When you create a way (a line), *OpenStreetMap* in reality only creates a set of nodes (points), and stores only the fact that the way is made of those.</span>.

The last thing you have to understand, is that information can be found only at the highest possible relevant level. In my case, the name of the cycle route is obviously stored at the *relation* level -- it would make no sense to duplicate it on every single road section of the itinerary -- whereas the presence of a dedicated cycle lane and its condition is stored at the *way* level -- indeed it may change from one section to the next. And how is it stored? It is a *tag*, attached the object, with a label and a value.

## Advanced access to filtered information

So now, how would you ask [*overpass turbo*](http://overpass-turbo.eu) to select all the *relations* with name "EuroVelo 3"? You would simply look for all *relations* possessing a *tag* with label `name` and with value `EuroVelo 3`. Under *Overpass API*'s conventions, this is written like this:

<aside><p class='remark' markdown='1'>If we were to also look for alternative spellings such as "eurovélo 3" or "ev3", we would replace <span class='breakproof'>`~"EuroVelo 3"`</span> by something like <span class='breakproof'>`~"([Ee]uro[Vv][eé]lo|EV|ev)( )?3"`</span> -- that's called a [regular expression](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions). Doing so is useful in order to find initiatives from individual mappers outside the [coordinated *EuroVelo* 3 task](http://wiki.openstreetmap.org/wiki/EV3), such as *relations* number [`4291999`](http://www.openstreetmap.org/relation/4291999) and [`6117075`](http://www.openstreetmap.org/relation/6117075).</p></aside>

    relation[name~"EuroVelo 3"]; out;

Magic or not, the first item in the list is the track of *The Pilgrims' Route*, or at least what exists of it on *OpenStreetMap*. The complete route is a *relation* with identifier [`299546`](http://www.openstreetmap.org/relation/2345035), and it has [its own page](http://wiki.openstreetmap.org/wiki/EV3) on the *OpenStreetMap*'s wiki.

<div class='wide'><img src="/img/screenshots/2016-06-07-overpass-part1.gif" class='screenshot'></div>

According to [the automatic page for *relation* `299546`](http://www.openstreetmap.org/relation/2345035), the European track is made of one sub-track by country crossed (Norway, Danmark, Sweden, Germany, Belgium, France and Spain), except for France where 11 sections (!) compete each other in the greatest confusion<label for="sn-storage" class="sidenote-number"></label><input type="checkbox" id="sn-storage"/><span class='sidenote'>Four of them are *sub-relations* of *relation* `299546`. One of them (number [`2345035`](http://www.openstreetmap.org/relation/2345035)) contains 8 tiny *sub-sub-relations* created by the same matryoshkaholic mapper, while an other (number `2888487`) is perfectly redundant to the one of the last two (number `2345035`).</span>.

But so far, we still did not access the actual itinerary. We just accessed the highest layer, the layer containing *relations*. To actually retreive coordinates, we must explicitly ask [overpass turbo](http://overpass-turbo.eu) to get down to the *way* level, then to the *node* level, and return the information at this level. Using the API's esoteric punctuation, such a request looks like the following:

    relation(299546);
    (._;>>;);
    out;

That's it, we're done! We can either watch the data in place, or download the data as `geoJSON` using the export button, transform it slightly with {% include logo.md what='r' %} and display it locally as a map<label for="sn-storage" class="sidenote-number"></label><input type="checkbox" id="sn-storage"/><span class='sidenote'>We will see the details in an other post.</span>. Obviously, some clean-up in France in needed.

<div id='map' class='wide high'></div>

<script>
    
  // SETTING ---------------------------------------------------------------
  var map = L.map('map', {
    minZoom: 3,
    touchZoom: false,
    scrollWheelZoom: false,
    center: [56, 30],
    zoom: 3
  })
  var relations = {};

  // chose a 'known provider' from there: http://leaflet-extras.github.io/leaflet-providers/preview/
  L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles &copy'
  }).addTo(map);

  $.getJSON("/data/2016-04-22-how-to-dowload-data-from-openstreetmap/osm2.geojson", function(data) {
    console.log(data);
    L.geoJson(data, {
      onEachFeature: function (feature, layer) {
        var relation      = feature.properties['@relations'][0];
        var relation_name = relation.reltags['name:en']==undefined ? relation.reltags['name'] : relation.reltags['name:en']
        relation = (relation_name.length > 30 ? relation_name.substr(0, 29)+'…': relation_name) + '<a href="http://www.openstreetmap.org/relation/' + relation.rel + '" style="float:right;margin-left:5px;">' + relation.rel + '</a>';
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
