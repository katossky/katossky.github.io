// UTILITIES -------------------------------------------------------------

function bounds2array(bounds){
  return([
    bounds.getWest(),
    bounds.getSouth(),
    bounds.getEast(),
    bounds.getNorth()
  ])
}

function array2bounds(array){
  var southWest = L.latLng(array[1], array[0]),
      northEast = L.latLng(array[3], array[2])
  return(
    new L.latLngBounds(southWest, northEast)
  )
}

$(document).ready(function(){

  // GLOBALS ---------------------------------------------------------------

  var blogPannel  = $("#blog-pannel");
  var blogContent = blogPannel.clone(true);
  var blogURL     = window.location.href;
  var blogTitle   = "A Ride on The Pilgrims' Route"; // document.title
  var blogScroll;

  var map = L.map('map-pannel', {minZoom: 4});

  // KEEPING TRACK WITH CHANGES --------------------------------------------

  blogPannel.on( 'state:update' , function(event, newState){
    
    var state;
    window.history.state==null ? state = {} : state = window.history.state;

    if(newState.mapbounds !=undefined) state.mapbounds = newState.mapbounds;
    if(newState.scroll    !=undefined) state.scroll    = newState.scroll;
    if(newState.content   !=undefined) state.content   = newState.content;
    if(newState.title     !=undefined) state.title     = newState.title;

    window.history.replaceState(state, "", window.location.pathname);
    console.log('Updated content of current navigation history state:');
    console.log( window.history.state );
  });
    
  // initialisation

  blogPannel.trigger('state:update', {
    content   : blogPannel.html(),
    title     : blogTitle,
    scroll    : blogPannel.scrollTop()
  })

  map.on('load', function(){
    blogPannel.trigger('state:update', { mapbounds: bounds2array(map.getBounds()) } );
  })

  // keeping track with scroll, move, zoom

  blogPannel.on( 'scroll', function(){
    console.log('Scroll!');
    blogPannel.trigger('state:update', {scroll: blogPannel.scrollTop()});
  }, 250)

  // map.on( 'moveend', function(){
  //  blogPannel.trigger('state:update', {mapbounds: map.getBounds()});
  // })

  // map.on( 'zoomend', function(){
  //  blogPannel.trigger('state:update', {mapbounds: map.getBounds()});
  // })

  // restoring previous stages with back and forth buttons

  window.onpopstate = function(e){
    console.log('Restoring previous state.');
    if(e.state){
      if(e.state.title)     document.title = e.state.title;
      if(e.state.content)   blogPannel.html(e.state.content);
      if(e.state.scroll)    blogPannel.scrollTop(e.state.scroll);
      if(e.state.mapbounds) map.flyToBounds(
        array2bounds(e.state.mapbounds),
        { maxZoom: 10 }
      );
      blogPannel.trigger('post:restore', e.state.selected);
    }
  };

  // CHARGING THE MAP --------------------------------------------

  map.setView([55, 5], 4);

  L.tileLayer(
    'http://server.arcgisonline.com/'+
    'ArcGIS/rest/services/World_Topo_Map/'+
    'MapServer/tile/{z}/{y}/{x}'
  ).addTo(map);

  $.getJSON("/data/2016-05-21-ev3.geojson").done(function( data ){

    var thePilgrimsRoute  = chargeThePilgrimsRoute( data );
    var dailyTracks       = chargeDailyTracks( thePilgrimsRoute );

    bindPilgrimsRouteInteractionEvents(thePilgrimsRoute);

  });

  function chargeThePilgrimsRoute( data ){

    var track = new L.geoJson(data, {
      opacity: 0.6,
      weight:  3.5
    });

    track = track.getLayers()[0];
    track.addTo( map );

    return( track );
  }

  // CHARGING THE TRACKS -----------------------------------------

  function chargeDailyTracks( thePilgrimsRoute ){

    var ids              = blogContent.find('li').map(function(){
      return($(this).attr('id'))
    });

    ids.each(function(index, id){

      $.getJSON( '/data/a-ride-on-the-pilgrims-route/' + id + '.geojson' )

      .done(function( data ){

        // 1. retreive the itinerary's departure and arrival

        var from = $.grep(data.features, function(f){
          return f.properties.stage === 'departure'
        });
        var to   = $.grep(data.features, function(f){
          return f.properties.stage === 'arrival'
        });
        from = turf.point( from[0].geometry.coordinates );
        to   = turf.point(   to[0].geometry.coordinates );

        // 2. create an approximate track along the whole itinerary
        
        var track = turf.lineSlice( from, to, thePilgrimsRoute.toGeoJSON() );
        track = new L.geoJson(track, {
          opacity:   0, // invisible
          weight:    5,
          color: '#ff6600'
        });
        track = track.getLayers()[0];
        track.addTo(map);

        // 3. attach events

        bindTrackInteractionEvents(id, track, thePilgrimsRoute);

      });

    });

  };

  // INTERACTIONS BLOG INDEX <-> MAP --------------------------------

  function bindTrackInteractionEvents(id, track, thePilgrimsRoute){

    // 1. highlight track when an entry is hovered

    blogPannel.on( 'mouseenter', 'li#'+id, function(){
      track.setStyle({opacity: 1});
    });
    blogPannel.on( 'mouseleave', 'li#'+id, function(){
      track.setStyle({opacity: 0});
    });

    // 2. conversely, highlight entry when track is hoovered

    // 3. zoom in when post is openned

    blogPannel.on( 'post:open', function(event, postId){

      if(id === postId){

        // highlight openned track
        track.setStyle({opacity: 1});

        // zoom-in
        map.flyToBounds(track, { maxZoom: 10 });

        // save bounds
        console.log('Open!')
        blogPannel.trigger('state:update', {
          mapbounds: bounds2array( track.getBounds() )
        });

      } else {

        // if post-open was triggered by an other post,
        // unhighlight the current track (in case it was highlighted for whatever reason)
        track.setStyle({opacity: 0});

      };

    });

    // 4.  zoom out when post is closed
    // 4a. un-highlight track

    // zoom itself is delegated outside the function
    // for avoiding beeing called multiple times

    blogPannel.on( 'post:close', function(){

      track.setStyle({opacity: 0});

    });

    // 5. highlight track when an entry is clicked
    // until post is closed or until an other entry is clicked

    // 6. highlight track on restore
    
    blogPannel.on( 'post:restore', function(event, postId){

      console.log(postId);

      if(id === postId){

        // highlight openned track
        track.setStyle({opacity: 1});

      } else {

        // unhighlight any other track
        // (in case it was highlighted for whatever reason)
        track.setStyle({opacity: 0});

      };

    });

  };

  function bindPilgrimsRouteInteractionEvents(thePilgrimsRoute){

    // 4b. proper zoom-out

    blogPannel.on( 'post:close', function(){

      // zoom-out
      map.flyToBounds(thePilgrimsRoute, { maxZoom: 10 });

      // save bounds
      console.log('Close!')
      blogPannel.trigger('state:update', {
        mapbounds: bounds2array( thePilgrimsRoute.getBounds() )
      });

    });

  };

  // BLOG PANNEL: POST PARTIAL LOADING ------------------------------------

  blogPannel.on( 'click', 'a', function(e){

    // prevent from going to the page
    e.preventDefault();

    // get the href
    var link    = $(this);
    var id      = link.parent('li').attr('id');
    var postURL = link.attr("href");
    // var trackID = $(this).parent().attr('id');
    console.log('Going to URL: ' + postURL);

    // save latest parameters of previous page
    var postScroll = blogPannel.scrollTop();
    blogPannel.trigger('state:update', {scroll: blogPannel.scrollTop()});

    $.get(postURL).done(function(text){

      var html        = $(text);
      var postTitle   = html.filter('title').text() ;
      var postContent = html.filter('#post').find('section > *') ;

      // update title
      document.title = postTitle;

      // update content
      blogPannel.empty().prepend(postContent).scrollTop(0);

      // implement a close button
      var button = $('<div id="close-button">×</div>');
      
      // add close button to the post
      button.prependTo(blogPannel);

      // create a new state in the navigation history
      window.history.pushState({
        content:   blogPannel.html(),
        title:     postTitle,
        scroll:    0,
        selected:  id
      }, "", postURL);
    
      console.log('Created the corresponding state in the navigation history.');

      // update map
      blogPannel.trigger('post:open', id);

    }).fail(function(){

       // handle errors here

    });

  });
  
  // BLOG PANNEL: CLOSING POST -----------------------------------------

  blogPannel.on( 'click', '#close-button', function(event){

    console.log('Going back to blog summary.');

    // save latest parameters of previous page
    var postScroll = blogPannel.scrollTop();
    blogPannel.trigger('state:update', {scroll: blogPannel.scrollTop()});

    // change html back to the blog entry list and reset map
    blogPannel.html(blogContent.html()).scrollTop(blogScroll);
    
    // update title
    document.title = blogTitle;

    // update URL
    window.history.pushState({
      content:   blogPannel.html(),
      title:     blogTitle
    }, "", blogURL);
    console.log('Created the corresponding state in the navigation history.');

    // update map
    blogPannel.trigger('post:close');

  });

});