var directionsDisplay;
var directionsService;
var marker;
var geocoder;
var map;
var infowindow;
var center;
var prefix;
var textfield;
//var mapcanvas;
var currentDirections = null;

function address_found_in_origin(value, element, paras){
  if(value != "")
    return false;
  else
    return true;
}
$.validator.addMethod("address_found", address_found_in_origin);
function initialize_map_origin_error_form(locale,address_not_found_message){
	var form_id = "#new_listing";
	var emptyfield = $('input[id$="google_address"]').attr("id");
  	translate_validation_messages(locale);
	$(form_id).validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.parent());
		},	
		rules: {
		  emptyfield: { required: true, minlength: 1 }
		  //"listing"[should_be_empty]": {:required: false, maxlength: 0}
			// "person[given_name]": {required: true, minlength: 2, maxlength: 30},
			// 			"person[family_name]": {required: true, minlength: 2, maxlength: 30},
			// 			"person[street_address]": {required: false, maxlength: 50},
			// 			"person[postal_code]": {required: false, maxlength: 8},
			// 			"person[city]": {required: false, maxlength: 50},
			// 			"person[phone_number]": {required: false, maxlength: 25}
		},
messages: {
"listing[should_be_empty]": { address_not_found: address_not_found_message }
} ,
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, locale, "true");
		}
	});	

}
// Marker
function googlemapMarkerInit(canvas,n_prefix,n_textfield,draggable) {
	prefix = n_prefix;
	textfield = n_textfield;
	if (draggable == undefined)
		draggable = false;
	var latitude = document.getElementById(prefix+ "_latitude");
	var longitude = document.getElementById(prefix+ "_longitude");
	if(latitude.value != null)
		center = new google.maps.LatLng(latitude.value,longitude.value);
	else
		center = new google.maps.LatLng(60.1894, 24.8358);
	var myOptions = {
		'zoom': 12,
		'center': center,
		'streetViewControl': false,
		'mapTypeControl': false,
        'mapTypeId': google.maps.MapTypeId.ROADMAP
    	}
	
	map = new google.maps.Map(document.getElementById(canvas), myOptions);
	geocoder = new google.maps.Geocoder();
	
	//update_map(source)
	
	marker = new google.maps.Marker({
		'map': map,
		'draggable': draggable,
		'animation': google.maps.Animation.DROP,
		'position': center
    });

	infowindow = new google.maps.InfoWindow();

    if (draggable){
	google.maps.event.addListener(map, "click", function(event) {
		marker.setPosition(event.latLng);
		marker.setVisible(true);
		geocoder.geocode({"latLng":event.latLng},update_source);
	});
	
	google.maps.event.addListener(marker, "dragend", function() {
		geocoder.geocode({"latLng":marker.getPosition()},update_source);
	});
    }

}

function update_map(field) {
  if(geocoder){
    geocoder.geocode({'address':field.value}, function(response,info) {
	if (info == google.maps.GeocoderStatus.OK){
	  marker.setVisible(true);
	  map.setCenter(response[0].geometry.location);
	  //field.value = response[0].formatted_address;
	  marker.setPosition(response[0].geometry.location);
	  // infowindow.close();
	  update_model_location(response);

	  //return true;
	  //Remove this when we get proper jquery stuff
	  //alert("Address " +field.value + " not found");
	} else {
	  //address_not_found(field);
	  //map.setCenter(center);
	  //map.panTo(center);
	  //marker.setPosition(center);
	  //marker.setVisible(false);
	  //$(mapcanvas).after("<div id=\"olol\"><label class=\"error\" for=\"person_street_address\" generated=\"true\">Please enter at least 4 characters.</label></div>");

	  // infowindow.setContent("Location " + field.value + " not found");
	  // infowindow.open(map, marker);

	  marker.setVisible(false);

	  nil_locations();
	}
    });
  }
  else
    return false;
}

function update_source(response,status){
  if (status == google.maps.GeocoderStatus.OK){
    update_model_location(response);
    source = document.getElementById(textfield);
    source.value = response[0].formatted_address;
		//update_location(response,source);
	} else {
	    //map.setCenter(new google.maps.LatLng(60.1894, 24.8358));
	    marker.setPosition(new google.maps.LatLng(60.1894, 24.8358));
	    marker.setVisible(false);
	    nil_locations();
	}
}
//Not used
function update_location(response, element){
	element.value = response[0].formatted_address;
	update_model_location(response);
}
function nil_locations(){
	var address = document.getElementById(prefix+ "_address");
	var latitude = document.getElementById(prefix+ "_latitude");
	var longitude = document.getElementById(prefix+ "_longitude");
	var google_address = document.getElementById(prefix+ "_google_address");
	address.value = null;
	latitude.value = null;
	longitude.value = null;
	google_address.value = null;
}
function update_model_location(place){
	var address = document.getElementById(prefix+ "_address");
	var latitude = document.getElementById(prefix+ "_latitude");
	var longitude = document.getElementById(prefix+ "_longitude");
	var google_address = document.getElementById(prefix+ "_google_address");
	
	// Changed this, need to discuss further
	//address.value = place[0].address_components[1].long_name + " " + place[0].address_components[0].long_name;
	address.value = place[0].address_components[0].long_name;
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
      } else {
		currentDirections = directionsDisplay.getDirections();
	  }
    });
}


// Use this one for "new" and "edit"
function startRoute() {
    var foo = document.getElementById("listing_origin").value;
    var bar = document.getElementById("listing_destination").value;
	directionsDisplay.setMap(map);
    document.getElementById("listing_origin_loc_attributes_address").value = foo;
    document.getElementById("listing_destination_loc_attributes_address").value = bar;

	// geocoder.geocode( { 'address': foo}, function(responce,status){
	// 	if (!(status == google.maps.GeocoderStatus.OK)) {
	// 		removeRoute();
	// 		if (!(document.getElementById("listing_origin").value == '')) {
	// 			wrongLocationRoute("listing_origin");
	// 			wipeFieldsRoute("listing_destination");
	// 		}
	// 	}
	// });
	// 
	// geocoder.geocode( { 'address': bar}, function(responce,status){
	// 	if (!(status == google.maps.GeocoderStatus.OK)) {
	// 		removeRoute();
	// 		if (!(document.getElementById("listing_destination").value == '')) {
	// 			wipeFieldsRoute("listing_origin");
	// 			wrongLocationRoute("listing_destination");
	// 		}
	// 	} 
	// });

	calcRoute(foo, bar);
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

// Route request to the Google API
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
