var directionsDisplay;
var directionsService;
var marker;
var geocoder;
var map;
var defaultCenter;
var infowindow;
var center;
var prefix;
var textfield;
var timer;
var currentDirections = null;

$.validator.
addMethod("address_validator",
  function(value, element, param) {
	  var check = null;
	
	  // Added to allow empty locations
	  if (value == "") {
		  return true;
	  }
	
    var pref = element.id.split("_");
    var elem_prefix ="";
    if (pref[0].match("person"))
      elem_prefix = "person";
    else
      elem_prefix = pref[0] + "_" + pref[1];

    var emptyfield = $('input[id$="latitude"][id^='+elem_prefix+']').attr("value") || "";
    if(emptyfield != "")
      check = true;
    else
      check = false;

    return check;
  }
);

function timed_input(param) {
  clearTimeout(timer);
  timer=setTimeout(
    function() {
      update_map(param);
    }, 
    1500
  );
}

function timed_input_on_route(){
  clearTimeout(timer);
  timer=setTimeout(function(){
      startRoute();
      }, 1500);
}

function googlemapMarkerInit(canvas,n_prefix,n_textfield,draggable) {
	prefix = n_prefix;
	textfield = n_textfield;
	defaultCenter = new google.maps.LatLng(60.1894, 24.8358);
	
	if (draggable == undefined)
		draggable = false;
		
	var latitude = document.getElementById(prefix+ "_latitude");
	var longitude = document.getElementById(prefix+ "_longitude");
	var visible = true;
	if(latitude.value != ""){
		center = new google.maps.LatLng(latitude.value,longitude.value);
	} else {
		center = defaultCenter;
		visible = false;
	}
	
	var myOptions = {
		'zoom': 12,
		'center': center,
		'streetViewControl': false,
		'mapTypeControl': false,
    'mapTypeId': google.maps.MapTypeId.ROADMAP
  }
	
	map = new google.maps.Map(document.getElementById(canvas), myOptions);
	geocoder = new google.maps.Geocoder();
	
	marker = new google.maps.Marker({
		'map': map,
		'draggable': draggable,
		'animation': google.maps.Animation.DROP,
		'position': center
  });

	infowindow = new google.maps.InfoWindow();

  if (draggable){
	  google.maps.event.addListener(map, "click", 
	    function(event) {
		    marker.setPosition(event.latLng);
		    marker.setVisible(true);
		    geocoder.geocode({"latLng":event.latLng},update_source);
	    }
	  );
	
	  google.maps.event.addListener(marker, "dragend", 
	    function() {
		    geocoder.geocode({"latLng":marker.getPosition()},update_source);
	    }
	  );
  }
  
  if(!visible)
	  marker.setVisible(false);
}

function update_map(field) {
  if (geocoder) {
    geocoder.geocode({'address':field.value}, 
      function(response,info) {
  	    if (info == google.maps.GeocoderStatus.OK){
  	      marker.setVisible(true);
  	      map.setCenter(response[0].geometry.location);
  	      marker.setPosition(response[0].geometry.location);
  	      update_model_location(response);
  	    } else {
  	      marker.setVisible(false);
  	      nil_locations();
  	    }
      }
    );
  } else {
    return false;
  }
}

function update_source(response,status){
  if (status == google.maps.GeocoderStatus.OK){
    update_model_location(response);
    source = document.getElementById(textfield);
    source.value = response[0].formatted_address;
	} else {
	  marker.setPosition(new google.maps.LatLng(60.1894, 24.8358));
	  marker.setVisible(false);
	  nil_locations();
	}
}

function manually_validate(formhint) {
  var rray = formhint.split("_");
  var form_id = "#";
  var _element = "#";

  if (rray[0].match("person")) {
    form_id += "person_settings_form";
    _element += "person_street_address";
  } else if (rray[0].match("listing")) {
    form_id += "new_listing_form";
    if (rray[1].match("origin")) {
      _element += "listing_origin";
    } else if(rray[1].match("destination")) {
      _element += "listing_destination";
    }
  }
  $(form_id).validate().element(_element);
}

function nil_locations(_prefix) {
  if (!_prefix)
    _prefix = prefix;
  var address = document.getElementById(_prefix+ "_address");
  var latitude = document.getElementById(_prefix+ "_latitude");
  var longitude = document.getElementById(_prefix+ "_longitude");
  var google_address = document.getElementById(_prefix+ "_google_address");
  address.value = null;
  latitude.value = null;
  longitude.value = null;
  google_address.value = null;
  manually_validate(_prefix);
}

function update_model_location(place,_prefix){
  if (!_prefix)
    _prefix = prefix;
  var address = document.getElementById(_prefix+ "_address");
  var latitude = document.getElementById(_prefix+ "_latitude");
  var longitude = document.getElementById(_prefix+ "_longitude");
  var google_address = document.getElementById(_prefix+ "_google_address");

	address.value = place[0].formatted_address;
  latitude.value = place[0].geometry.location.lat();
  longitude.value = place[0].geometry.location.lng();
  google_address.value = place[0].formatted_address;
  manually_validate(_prefix);
}



// Rideshare
function googlemapRouteInit(canvas) {

  geocoder = new google.maps.Geocoder();
  directionsService = new google.maps.DirectionsService();
  defaultCenter = new google.maps.LatLng(60.1894, 24.8358);
	
  var myOptions = {
    'mapTypeId': google.maps.MapTypeId.ROADMAP,
    'disableDefaultUI': false,
	  'streetViewControl': false,
	  'mapTypeControl': false
  }

  map = new google.maps.Map(document.getElementById(canvas), myOptions);

  var markerOptions = {
	  'animation': google.maps.Animation.DROP
  }

  directionsDisplay = new google.maps.DirectionsRenderer({
    'map': map,
	  'hideRouteList': true,
    'preserveViewport': false,
    'draggable': false,
	  'markerOptions': markerOptions
  });

  google.maps.event.addListener(directionsDisplay, 'directions_changed', 
    function() {
      if (currentDirections) {
	      //updateTextBoxes();
      } else {
		    currentDirections = directionsDisplay.getDirections();
	    }
    }
  );
}


// Use this one for "new" and "edit"
function startRoute() {
  var foo = document.getElementById("listing_origin").value;
  var bar = document.getElementById("listing_destination").value;
	directionsDisplay.setMap(map);
  document.getElementById("listing_origin_loc_attributes_address").value = foo;
  document.getElementById("listing_destination_loc_attributes_address").value = bar;

  if(foo != '' && bar != '') {
    calcRoute(foo, bar);
  } else {
    removeRoute();
    if (foo == '' && bar == '') {
	    map.setCenter(defaultCenter);
    	map.setZoom(12);
    }
  }
}

function wrongLocationRoute(field){
  document.getElementById(field).value = "Address not found";
  document.getElementById(field+"_loc_attributes_address").value = null; 
  document.getElementById(field+"_loc_attributes_google_address").value = null; 
  document.getElementById(field+"_loc_attributes_latitude").value = null;
  document.getElementById(field+"_loc_attributes_longitude").value = null;
}

function wipeFieldsRoute(field) {
  document.getElementById(field+"_loc_attributes_address").value = null; 
  document.getElementById(field+"_loc_attributes_google_address").value = null; 
  document.getElementById(field+"_loc_attributes_latitude").value = null;
  document.getElementById(field+"_loc_attributes_longitude").value = null;
}

function removeRoute() {
  directionsDisplay.setMap(null);	
}


// Use this one for "show"
function showRoute(orig, dest) {
  var start = orig;
  var end = dest;
    
  var request = {
    origin:start,
    destination:end,
    travelMode: google.maps.DirectionsTravelMode.DRIVING,
    unitSystem: google.maps.DirectionsUnitSystem.METRIC
  };
  
  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      directionsDisplay.setDirections(response);
    } 
  });
}

function route_not_found(orig, dest) {
  if (orig) {
	  geocoder.geocode( { 'address': orig}, function(response, status){
	 	  if (!(status == google.maps.GeocoderStatus.OK)) {
        nil_locations("listing_origin_loc_attributes");
	 		  removeRoute();
	 	  } else {
        update_model_location(response, "listing_origin_loc_attributes");
		  }
	  });
  } else { 
	  nil_locations("listing_origin_loc_attributes");
  }
  if (dest) {
	  geocoder.geocode( { 'address': dest}, function(responce,status){
	 	  if (!(status == google.maps.GeocoderStatus.OK)) {
        nil_locations("listing_destination_loc_attributes");
  	 		removeRoute();
  	 	} else {
        update_model_location(responce, "listing_destination_loc_attributes");
        calcRoute(foo, bar);
  		}
	  });
  } else {
	  nil_locations("listing_destination_loc_attributes");
  }
}

// Route request to the Google API
function calcRoute(orig, dest) {
  var start = orig;
  var end = dest;
  
  if(!orig.match(dest)){

    var request = {
      origin:start,
      destination:end,
      travelMode: google.maps.DirectionsTravelMode.DRIVING,
      unitSystem: google.maps.DirectionsUnitSystem.METRIC
    };
    
    directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
   	    directionsDisplay.setDirections(response);
        updateEditTextBoxes();
      } else {
        removeRoute();
        route_not_found(orig,dest);
      }
    });
  } else {
    removeRoute();
  }
}

function updateEditTextBoxes() {
  var foo = directionsDisplay.getDirections().routes[0].legs[0].start_address;
  var bar = directionsDisplay.getDirections().routes[0].legs[0].end_address;
  document.getElementById("listing_origin_loc_attributes_google_address").value = foo; 
  document.getElementById("listing_destination_loc_attributes_google_address").value = bar;
  document.getElementById("listing_origin_loc_attributes_latitude").value = directionsDisplay.getDirections().routes[0].legs[0].start_location.lat();
  document.getElementById("listing_origin_loc_attributes_longitude").value = directionsDisplay.getDirections().routes[0].legs[0].start_location.lng();
  document.getElementById("listing_destination_loc_attributes_latitude").value = directionsDisplay.getDirections().routes[0].legs[0].end_location.lat();
  document.getElementById("listing_destination_loc_attributes_longitude").value = directionsDisplay.getDirections().routes[0].legs[0].end_location.lng();
  manually_validate("listing_destination");
  manually_validate("listing_origin");
}