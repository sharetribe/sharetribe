var directionsDisplay;
<<<<<<< HEAD
=======
//var directionsService = new google.maps.DirectionsService();
>>>>>>> googlemaps.js
var directionsService;
var geocoder;
var map;
var latlng;
var currentDirections = null;

function googlemapInit(canvas) {

  geocoder = new google.maps.Geocoder();
  latlng = new google.maps.LatLng(60.169, 24.938);
  directionsService = new google.maps.DirectionsService();
	
  var myOptions = {
    'zoom': 10,
    'mapTypeId': google.maps.MapTypeId.ROADMAP,
    'disableDefaultUI': false,
	'streetViewControl': false,
	'mapTypeControl': false
  }

  map = new google.maps.Map(document.getElementById(canvas), myOptions);

  directionsDisplay = new google.maps.DirectionsRenderer({
    'map': map,
	'hideRouteList': true,
    'preserveViewport': false,
    'draggable': false,
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

// elementId: Specify the element.src where you want to display the static map.
function loadStaticMap(elementId) {
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
