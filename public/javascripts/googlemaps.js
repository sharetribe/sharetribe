var directionsDisplay;
//var directionsService = new google.maps.DirectionsService();
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
    'center': latlng,
    'mapTypeId': google.maps.MapTypeId.ROADMAP,
    'disableDefaultUI': true,
	'streetViewControl': false
  }

  map = new google.maps.Map(document.getElementById(canvas), myOptions);

  directionsDisplay = new google.maps.DirectionsRenderer({
    'map': map,
	'hideRouteList': true,
    'preserveViewport': false,
    'draggable': true,
  });

  google.maps.event.addListener(directionsDisplay, 'directions_changed', function() {
    if (currentDirections) {
	  updateTextBoxes();
      }
	currentDirections = directionsDisplay.getDirections();
    });

  startCopy();
}

function startCopy() {
	document.getElementById("listing_origin_loc_attributes_google_address").value = document.getElementById("listing_origin").value;
	document.getElementById("listing_destination_loc_attributes_google_address").value = document.getElementById("listing_destination").value;
	calcRoute();
}

function calcRoute() {
  var start = document.getElementById("listing_origin_loc_attributes_google_address").value;
  var end = document.getElementById("listing_destination_loc_attributes_google_address").value;
  //var start = "Helsinki";
  //var end = "Vantaa";
    
  var request = {
    origin:start,
    destination:end,
    travelMode: google.maps.DirectionsTravelMode.DRIVING,
    unitSystem: google.maps.DirectionsUnitSystem.METRIC
  };
  
  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      directionsDisplay.setDirections(response);
      updateTextBoxes();
    }
  });
  loadStaticMap();
}

function copyGooglePoints() {
	document.getElementById("listing_origin").value = document.getElementById("listing_origin_loc_attributes_google_address").value;
	document.getElementById("listing_destination").value = document.getElementById("listing_destination_loc_attributes_google_address").value;
	startCopy();
}

function updateTextBoxes() {
  document.getElementById("listing_origin_loc_attributes_google_address").value = directionsDisplay.getDirections().routes[0].legs[0].start_address;
  document.getElementById("listing_destination_loc_attributes_google_address").value = directionsDisplay.getDirections().routes[0].legs[0].end_address;
}

function loadStaticMap() {
  var baseUrl = "http://maps.google.com/maps/api/staticmap?";
  var params = []; // The static map request parameters
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
	
	//document.getElementById("steps").value = directionsDisplay.getDirections().routes[0].overview_path.length;
	//document.getElementById("steps").value = latlngArray.length;

	
	var polyOptions = {
      path: latlngArray
	}
	var poly = new google.maps.Polyline(polyOptions);
	//poly.setMap(map); // draw the polyline to the Javascript map
	var encodeString = google.maps.geometry.encoding.encodePath(poly.getPath());
	//document.getElementById("encoded_string").value = encodeString;
		
	// Size
	params.push("size=400x300");
	
	// Start and End Markers
	params.push("markers=" + markerString);
	
	// Polyline Path
	params.push("path=weight:5%7Ccolor:blue%7Cenc:" + encodeString);
	
	// Sensor to false
	params.push("sensor=false");
	
	// Center -- Not needed with polyline
	//params.push("center=" + directionsDisplay.getMap().getCenter().lat().toFixed(6) + "," + directionsDisplay.getMap().getCenter().lng().toFixed(6));
	
	// Zoom -- Not needed with polyline
	//var zoomLevel = directionsDisplay.getMap().getZoom() - 2;
	//params.push("zoom=" + zoomLevel);
	
	baseUrl += params.join("&");
	
    //document.getElementById("listing_description").value = baseUrl;
	//document.getElementById("static_google").value = baseUrl; // The textbox
	//document.getElementById("staticMap").src = baseUrl; // The image
  }