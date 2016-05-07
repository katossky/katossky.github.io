---
layout: page
title:  A mistery full of dots
---

While I was [investigating the Overpass API](/data/2016/04/23/overpass-API.html), I was confronted to a weird problem, namely that the data I downloaded from OpenStreetMap is absolutely full with dots. "And what?", are you maybe thinking. If you do not see what is wrong with this, you have to [remember]() that the data I am trying to download concerns a biking route ([the Eurovelo 3 route]()) and that as a route, it should contain much more lines (or *ways* in OpensStreetMap's world) than dots (or *nodes*)!

You can experiment this strange behaviours yourself with the data for the route in Norway. You can either trust me and download the file from [here]() or you can go yourself to the Overpass API ([this]()) and run the following request:





The points are terribly slowing down the display of the map. To what do those dots correspond?


I found the solution through R, my favourite statistical software, even thought there is no doubt other solutions may exist out there.

    library(dplyr)    # %>%
    library(stringr)  # str_detect
    library(jsonlite) # fromJSON, toJSON
    fromJSON('name-of-input.geojson') %>%
      with(features <- features[str_detect(features$properties$`@id`, '^way'),]) %>%
      toJSON(Data) %>%
      cat(file ='name-of-output.geojson')