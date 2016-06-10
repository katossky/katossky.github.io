---
layout:     post
title:      A Planner for the Pilgrims' Route
categories: [Journey Planner - The Making of]
tags:       [Radnetz, Eurovelo network, Eurovelo 3]
thumbnail:  /img/thumbnails/a-planner-for-the-pilgrims-route.png
summary:    
---

Once I took the decision to ride [*The Pilgrims' Route*]({% post_url 2016-01-01-the-pilgrims-route %}) from Trondheim to Santiago this summer, I quickly realised than there did not exist any dedicated cycle map. The *EuroVelo* network, in which *The Pilgrims' Route* has number 3, is every day more complete, but it still has too few cyclists to interest major map editors.

But actually, it was even almost impossible at first to get a mere GPS track of the route<label for="sn-data-quest" class="sidenote-number"></label><input type="checkbox" id="sn-data-quest"/><span class='sidenote'>A forthcoming post will describe my quest for the GPS track for *The Pilgrims' Route* ending up on the online track manager [*Biroto*](http://www.biroto.eu). I still wonder why the *EuroVelo* network itself does not provide the GPS tracks of the routes. I guess the only argument for not providing this basic low-cost service is that the network is not yet complete -- it is expected to be completed in 2020 -- and that parts of the itineraries are not yet decided.</span>. Missingness of navigation data is a huge obstacle to the development of bike tourism. Germany is maybe the most advanced European country for long-distance bike trips, and at least does the German counterpart to *EuroVelo*, [*dnetz*]({% post_url 2016-05-18-radnetz-deutschland %}), provide the GPS tracks for its network.

<div>
  <a href="http://www.eurovelo.com/en/eurovelos/eurovelo-3/countries/belgium"><img src="/img/2016-06-06-ev3-belgium.png"></a>
  <p class='legend' markdown='1'>***EuroVelo* 3 map in Belgium.** If you browse the *EuroVelo* website, you can find low-resolution situation maps, like here in Belgium. But nothing that a tourer can actually use, be it for planning the trip or for navigating on the bike.</p>
</div>

Now, let's imagine you have collected, one way or another, a GPS file for your full trip. Do you thing you are done? Of course not: you need a tool to read and use the track. And it is not as easy at it seems to read a track of more than 5000 km. And even less convenient to contrast it to other source of information such as list of hotels, campings, restaurants, supermarkets... that you will use by hundreds.

Luckily some independant initiatives have been trying to complement the lack of proper long-distance bike planners. One of the first one I encountered was  [northsea-cycle.com](http://www.northsea-cycle.com), a website dedicated to route Eurovelo 12, [*The North Sea*](http://www.eurovelo.com/en/eurovelos/eurovelo-12).

<div class="wide">
	<a href="http://www.northsea-cycle.com"><img class='screenshot' src="/img/screenshots/2016-04-07-www-northsea-cycle-com.jpg"/></a>
    <p class='legend full-width' markdown='1'>[**northsea-cycle.com**](http://www.northsea-cycle.com){: .very-discreet} is a website developed and maintained by the municipality of Stavanger (Norway), displaying Eurovelo 12 route track on a zoomable, interactive map. A handful variants are provided (in green) as well as a sparse selection of "cyclist friendly" accomodations. Users can register and edit their version of the map, as well as share their comments with other cyclists and download data. The municipality of Stavanger additionnally delivers diplomas for the happy few who complete the trip.</p>
</div>

Other useful websites include [*OpenCycleMap*](http://www.opencyclemap.org), a website displaying bike-related information stored under the *OpenStreetMap* project ; [*Biroto*](http://www.biroto.eu/en) and [*Bikemap*](https://www.bikemap.net), two platforms for sharing bike trips between users; and [*Naviki*](https://www.naviki.org), an automated route planner for bikes. Unfortunately, *Biroto* terribly lacks user-friendliness whereas the others do not offer any help in planning a long distance trip.

<aside class='remark'><p>A <em>Google</em> search for "bike journey / stage / route planner" gives many hits, but none of which is useful for planning the stages on a long-distance journey. I can roughly and quickly define two categories:<ol><li>the applications destinated to monitor perfomance (speed, calory consumption) on hours-long trips, often augmented with a track sharing system for emulation between users;</li><li>the journey planners oriented towards commuting and transportation rather than sport.</li></ol></p></aside>

<div>
	<img src="/img/screenshots/2016-06-06-google-trondheim-santiago.png">
	<p class='legend' markdown='1'>**201 hours from Norway to Spain.** *Google Map* is clearly not part of the useful tools. Does "201 hours" mean that the journey would take you 40 days if you cycle 5 hours a day?</p>
</div>
<!-- Google screenshot: ... what does it make as regular biking days?  Who care about it takes ... hours between ... and ...? How many *days* of regular cycling does it take? Real world questions look like this: If I have only 20 days between Hamburg and Paris, can I afford 2 days in Maastricht?

Of course the answer depend on the person asking the question. Some people do travel light and can do 200 km a day on their racing bike while some others do love wandering around, stopping at castles, tasting wine, collecting treasure and hardly do 60 km. But both face the same problems: eating, sleeping, passing by or stopping at interesting places.-->

In other words, I cannot find the tool I would like to prepare [my 4-months trip]({% post_url 2016-01-01-the-pilgrims-route %}) is missing, and I cannot believe either that I am the only one to feel that way. That is why I am decided to build this tool myself. I will start with *The Pilgrims' Route* itself, and will try to enrich the bare GPS track with relevant data. Only afterwards will I consider additionnal marked routes.

Here are the basic features I would like to implement:

- access to the whole track on a zoomable, interactive map, without password
- ability to download the whole GPS track in a wide range of formats
- seamless alternation between 2 views: classical map view ; journey-planner view
- display of basic information<label for="sn-basic-info" class="sidenote-number"></label><input type="checkbox" id="sn-basic-info"/><span class='sidenote'>The display of this information should not overload the map and change at different zoom levels. A clear hierarchy should exist between elements. Undesired information should be hideable.</span>: restaurants ; hotels, campings and shelters ; touristic attractions ; bike shops and workshops
<!-- Rome2Rio as an exemple -->
- few variants for major sights of interest or major shortcuts
- most importantly, assisted stage planning, under a combination of space and time constraints<label for="sn-stage-plan" class="sidenote-number"></label><input type="checkbox" id="sn-stage-plan"/><span class='sidenote'>The basic implementation takes into account the desired starting point, destination, and overall duration and gives the possibility to save the customised version of the route. A limited number of options should be available: level of effort (from 50 to 100 km a day), level of confort (hotel vs. wild camping; restaurant vs. groceries), stopovers in touristic cities (2 days in Oslo, 5 days in Paris for instance).</span>

Extra features could include:

- a version of the tool usable on a mobile device
- a "loose" planning mode enabling users to plan only a few stages at a time, following the advancement of the journey, the detail of the remaining part of the trip being averaged out
- addition of a third, "rectified" map view (useful on mobile devices and for navigation)

<div class='wide'>
	<img src="/img/2016-06-06-26.png">
	<p class='legend' markdown='1'>**Rectified representation of Parisian bus route 26.** Compared to the true, sinuous representaiton of the route, the horizontal rectification simplifies the reading of the different stops -- all aligned regularly -- while preserving locally the configuration of the road network (angles, distances). In the case of a bike travel, the vertical rectification would ease the reading of information accompanying the track (next village, next touristic point) as well as simplify the orientation.</p>
</div>

- synchronisation with *OpenStreetMap*<label for="sn-synchro" class="sidenote-number"></label><input type="checkbox" id="sn-synchro"/><span class='sidenote'>It is not vital to the project but it is fair to the *OpenStreetMap* community, who make my project possible in the first place.</span>
- accomodation booking
- tourist attractions booking
- "you're here" sign and GPS integration
- possibility to add comments / pictures / videos on the track
- possibility to chat with and pair up with other travellers
- transportation from/to journey endpoits
- variants to arbitrary destinations

As we say in French, [*j'ai du pain sur la planche*]({% post_url 2016-06-05-avoir-du-pain-sur-la-planche %}).