---
layout:   page
title:    The Eclectic Cyclist
---

<section id='blog-showcase' markdown='1'>
  
# THE ECLECTIC CYCLIST

## Why this website?

Starting on July, 1<sup>st</sup>, I will be riding my bike accross Europe from Trondheim (Norway) to Santiago (Spain) along *The Pigrims' Route*, route number 3 in the *EuroVelo* network. This website is mainly about my trip, but I will also write about my other pleasures in life: mapping, cooking, gardening and statistics.

## What can I find here?

For now, this site is hosting a series of topical blogs, especially two about my bike tour: one about the trip itself ([*A ride on The Pilgrims' Route*](/blogs/a-ride-on-the-pilgrims-route)), and one about the cycling politicies of the different countries I will visit ([*The Cycling Strategy*](/blogs/the-cycling-strategy)). You will also soon find a journey planner, intended for helping those who also want to ride *The Pigrims' Route*.

## Latest posts

<ul class='post-list'>
  {% for post in site.posts %}
  {% assign content = post.content | strip_newlines %}
  {% if content != '' %}
  <li  class='post-vignette'>
    <a href="{{ post.url }}">
      <img src='{{ post.thumbnail }}'/>
      <p>
        <span class='date'>{{ post.date | date: "%d/%m/%Y" }}</span>
        <span class='title'>{{ post.title }}</span>
      </p>
    </a>
  </li>
  {% endif %}
  {% endfor %}
</ul>

</section>

<div id='curl-effect'>
  <a href="/journey-planner"><div></div></a>
</div>

<!--<section id='project-showcase'>
  <a href='plan-your-journey-on-the-pilgrims-route'><div class='project' id='plan-your-journey'>
    <div id='plan-your-journey-icon'>
      <i class="fa fa-map-signs fa-5x" aria-hidden="true">
      <span class="direction-from">Trondheim</span>
      <span class="direction-to">Santiago</span>
      </i>
    </div>
    <p>Plan your <i class="fa fa-bicycle" aria-hidden="true"></i> trip on</p>
    <p> <strong><em>The Pilgrims' Route</em></strong></p>
  </div></a>
</section>-->