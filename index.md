---
layout:   default
title:    Arthur Katossky
---

<section id='blog-showcase' markdown='1'>
  
# THE ECLECTIC CYCLIST

**Why this website?** Starting on July, 1<sup>st</sup>, I will be riding my bike accross Europe from Trondheim (Norway) to Santiago (Spain) along *The Pigrim Way*. I simultaneously decided it was good timing for launching a website that would summarize my diverse activities: from statistics to cooking, from biking to gardening.

**What can I find here?** For now, this site is hosting **a journey planner**, in construction, for those who want to follow me on *The Pigrim way* and a series of topical blogs.

# LATEST POSTS

<!-- latest posts -->
<ul class='post-list'>
  <!--<li class='post-vignette'><img src="/img/eurovelo-3-track.png"><p><strong>Latest posts</strong></p></li>-->
  {% for post in site.posts %}
  <li  class='post-vignette'>
    <a href="{{ post.url }}">
      <img src='{{ post.thumbnail }}'/>
      <p>
        <span class='date'>{{ post.date | date: "%d/%m/%Y" }}</span>
        <span class='title'>{{ post.title }}</span>
      </p>
    </a>
  </li>
  {% endfor %}
</ul>

</section>

<section id='project-showcase'>
  <div class='project'>
    <!--<div class='image-container'>
      <div class='screen'></div>
      <img src="/img/eurovelo-3-route.png">
    </div>-->
    <i class="fa fa-map-signs fa-5x" aria-hidden="true">
      <span class="direction-from">Trondheim</span>
      <span class="direction-to">Santiago</span>
    </i>
    <div>
      <p>Plan your <i class="fa fa-bicycle" aria-hidden="true"></i> trip on</p>
      <p> <strong><em>The Pilgrim way</em></strong></p>
    <div>
  </div>
</section>