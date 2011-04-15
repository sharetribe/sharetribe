var directionsDisplay;
var directionsService;
var marker;
var geocoder;
var map;
var center;
var currentDirections = null;

// Marker
function googlemapMarkerInit(canvas) {
	center = new google.maps.LatLng(60.1894, 24.8358);
	var myOptions = {
		'zoom': 12,
		'center': center,
		'streetViewControl': false,
		'mapTypeControl': false,
        'mapTypeId': google.maps.MapTypeId.ROADMAP
    	}
	// }
	
	map = new google.maps.Map(document.getElementById(canvas), myOptions);
	geocoder = new google.maps.Geocoder();
	
	if(update_map(source)){
	}
	
	marker = new google.maps.Marker({
		'map': map,
		'draggable': true,
		'animation': google.maps.Animation.DROP,
		'position': center
    });

	google.maps.event.addListener(map, "click", function(event) {
		marker.setPosition(event.latLng);
		marker.setVisible(true);
		geocoder.geocode({"latLng":event.latLng},update_source);
	});
	
	google.maps.event.addListener(marker, "dragend", function() {
		geocoder.geocode({"latLng":marker.getPosition()},update_source);
	});
}

function update_map(field) {
	if(geocoder){
	  geocoder.geocode({'address':field.value}, function(response,info) {
        if (info == google.maps.GeocoderStatus.OK){
	    	map.setCenter(response[0].geometry.location);
	    	field.value = response[0].formatted_address;
	    	marker.setPosition(response[0].geometry.location);
			marker.setVisible(true);
	    if (profilemap)
	    	update_profile_location(response);

	    return true;
		    //Remove this when we get proper jquery stuff
              //alert("Address " +field.value + " not found");
            } else {
	    	address_not_found(field);
			map.setCenter(new google.maps.LatLng(60.1894, 24.8358));
			marker.setPosition(new google.maps.LatLng(60.1894, 24.8358));
			marker.setVisible(false);
			nil_profile_locations();
            }
		});
	}
	else
		return false;
}

// function update_map(field) {
// 	if(geocoder){
// 	  geocoder.geocode( {'address':field.value}, function(response,info) {
//       	
// 		if (info == google.maps.GeocoderStatus.OK) {
// 		    map.setCenter(response[0].geometry.location);
// 	    	field.value = response[0].formatted_address;
// 	    	marker.setPosition(response[0].geometry.location);
// 	    	marker.setVisible(true);
// 	    	
// 			if (profilemap) {
// 	    		update_profile_location(response);
// 			}
// 	    	
// 			return true;	
// 		    
// 		} else {
// 	    	address_not_found(field);
// 			map.setCenter(new google.maps.LatLng(60.1894, 24.8358));
// 			marker.setPosition(new google.maps.LatLng(60.1894, 24.8358));
// 			marker.setVisible(false);
// 			nil_profile_locations();
// 		}
// 	});
// 	}
// 	else
// 		return false;	
// }
function update_source(response,status){
	if (status == google.maps.GeocoderStatus.OK){
		update_location(response,source);
	} else {
	    map.setCenter(new google.maps.LatLng(60.1894, 24.8358));
	    marker.setPosition(new google.maps.LatLng(60.1894, 24.8358));
	    marker.setVisible(false);
	    nil_profile_locations();
	}
}
function update_location(response, element){
	element.value = response[0].formatted_address;
	if(profilemap) {
		update_profile_location(response);
	}
}
function nil_profile_locations(){
	var address = document.getElementById("person_location_address");
	var latitude = document.getElementById("person_location_latitude");
	var longitude = document.getElementById("person_location_longitude");
	var google_address = document.getElementById("person_location_google_address");
	address.value = null;
	latitude.value = null;
	longitude.value = null;
	google_address.value = null;
}
function update_profile_location(place){
	var address = document.getElementById("person_location_address");
	var latitude = document.getElementById("person_location_latitude");
	var longitude = document.getElementById("person_location_longitude");
	var google_address = document.getElementById("person_location_google_address");
	address.value = place[0].address_components[1].long_name + " " + place[0].address_components[0].long_name;
	latitude.value = place[0].geometry.location.lat();
	longitude.value = place[0].geometry.location.lng();
	google_address.value = place[0].formatted_address;
}



// Rideshare
function googlemapRouteInit(canvas) {

  geocoder = new google.maps.Geocoder();
  directionsService = new google.maps.DirectionsService();
	
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

  google.maps.event.addListener(directionsDisplay, 'directions_changed', function() {
    if (currentDirections) {
	  //updateTextBoxes();
      }
	currentDirections = directionsDisplay.getDirections();
    });
}

// Use this one for "new" and "edit"
function startRoute() {
    var foo = document.getElementById("listing_origin").value;
    var bar = document.getElementById("listing_destination").value;
    document.getElementById("listing_origin_loc_attributes_address").value = foo;
    document.getElementById("listing_destination_loc_attributes_address").value = bar;
	calcRoute(foo, bar);
}

// Rideshare creation
function calcRoute(orig, dest) {
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
      updateEditTextBoxes();
    }
  });
}

function updateEditTextBoxes() {
  var foo = directionsDisplay.getDirections().routes[0].legs[0].start_address;
  var bar = directionsDisplay.getDirections().routes[0].legs[0].end_address;
  document.getElementById("listing_origin_loc_attributes_google_address").value = foo; 
  document.getElementById("listing_destination_loc_attributes_google_address").value = bar;
  document.getElementById("listing_origin_loc_attributes_latitude").value = directionsDisplay.getDirections().routes[0].legs[0].end_location.lat();
  document.getElementById("listing_origin_loc_attributes_longitude").value = directionsDisplay.getDirections().routes[0].legs[0].end_location.lng();
  document.getElementById("listing_destination_loc_attributes_latitude").value = directionsDisplay.getDirections().routes[0].legs[0].start_location.lat();
  document.getElementById("listing_destination_loc_attributes_longitude").value = directionsDisplay.getDirections().routes[0].legs[0].start_location.lng();
}

// Rideshare viewing
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

// elementId: Specify the element.src where you want to display the static map.
function loadStaticRouteMap(elementId) {
  var baseUrl = "http://maps.google.com/maps/api/staticmap?";
  var parser = []; // The static map request parameters
  var latlngArray = []; // An array of latlng-values for the polyline
  var markerString = ""; // A and B markers, should be replaced by two separate arguments	
	
  var overview_length = directionsDisplay.getDirections().routes[0].overview_path.length;
	for (i = 0; i < overview_length; i++) {
		var m = directionsDisplay.getDirections().routes[0].overview_path[i];
		latlngArray[i] = m;
		if (i == 0) {
			markerString += directionsDisplay.getDirections().routes[0].legs[0].start_location.toUrlValue() + "|";
		}
		if (i == overview_length-1) {
			markerString += directionsDisplay.getDirections().routes[0].legs[0].end_location.toUrlValue();
		}
	}
	
	var polyOptions = {
      path: latlngArray
	}
	var poly = new google.maps.Polyline(polyOptions);
	//poly.setMap(map); // draw the polyline to the Javascript map
	var encodeString = google.maps.geometry.encoding.encodePath(poly.getPath());
		
	// Size
	parser.push("size=640x640");
	
	// Start and End Markers
	parser.push("markers=" + markerString);
	
	// Polyline Path
	parser.push("path=weight:5%7Ccolor:blue%7Cenc:" + encodeString);
	
	// Sensor to false
	parser.push("sensor=false");
	
	// Center -- Not needed with polyline
	//parser.push("center=" + directionsDisplay.getMap().getCenter().lat().toFixed(6) + "," + directionsDisplay.getMap().getCenter().lng().toFixed(6));
	
	// Zoom -- Not needed with polyline
	//var zoomLevel = directionsDisplay.getMap().getZoom() - 2;
	//parser.push("zoom=" + zoomLevel);
	
	baseUrl += parser.join("&");
	document.getElementById(elementId).src = baseUrl;
}
