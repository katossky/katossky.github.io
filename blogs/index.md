---
layout: default
title:  Blogs
---

<section id='blog-showcase' markdown='1'>
{% for category in site.categories %}

# {{ category[0] }}

<ul class='post-list'>
  <!--<li class='post-vignette'><img src="/img/eurovelo-3-track.png"><p><strong>Latest posts</strong></p></li>-->
  {% for post in category[1] %}
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

{% endfor %}
</section>