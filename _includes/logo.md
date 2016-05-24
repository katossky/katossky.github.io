{% case include.what %}
{% when 'eURovelo' %} <a href="/eurovelo"><span style='font-weight:900'>e</span><span style='font-weight:100'>UR</span><span style='font-weight:900'>ovelo</span></a>
{% when 'eurovelo' %} [![Eurovelo](/img/logos/eurovelo.png)](http://www.eurovelo.com/en){: .logo}
{% when 'ev3' %} [![EV3](/img/logos/ev3.png)](http://www.eurovelo.com/en/eurovelos/eurovelo-3){: .logo}
{% when 'ev6' %} [![EV6](/img/logos/ev6.png)](http://www.eurovelo.com/en/eurovelos/eurovelo-6){: .logo}
{% when 'leaflet' %} [![Leaflet](/img/logos/leaflet.png)](http://leafletjs.com){: .logo}
{% when 'r' %} [![R](/img/logos/r.png)](https://www.r-project.org){: .logo}
{% when 'chamina' %} <img src="/img/logos/chamina.png" title='Chamina'>
{% endcase %}