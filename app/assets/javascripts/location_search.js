window.ST = window.ST || {};

(function(module) {

  module.initializeLocationSearch = function initializeLocationSearch(selectors) {
    var searchInput = document.querySelector(selectors.search);
    var statusInput = document.querySelector(selectors.status);
    var coordinateInput = document.querySelector(selectors.coordinate);
    var boundingboxInput = document.querySelector(selectors.boundingbox);
    var maxDistanceInput = document.querySelector(selectors.maxDistance);
    var form = document.querySelector(selectors.form);
    var autocomplete = new window.google.maps.places.Autocomplete(searchInput, { bounds: { north: -90, east: -180, south: 90, west: 180 } });
    var locationQueryMade = false;
    var sessionToken = null;
    autocomplete.setTypes(['geocode']);
    autocomplete.setFields(['address_components', 'geometry', 'icon', 'name']);


    // The values of these fields are defined based on the value of searchInput
    function clearHiddenInputs() {
      statusInput.value = null;
      coordinateInput.value = null;
      boundingboxInput.value = null;
      maxDistanceInput.value = null;
    }

    function toRadians(degrees) {
      return degrees * (Math.PI/180);
    }

    function computeScale(a, b) {
      var R = 6371; // Earth's radius in km

      var lat1 = a.lat();
      var lat2 = b.lat();
      var lng1 = a.lng();
      var lng2 = b.lng();
      var lat1InRadians = toRadians(lat1);
      var lat2InRadians = toRadians(lat2);
      var latDiffInRadians = toRadians(lat2-lat1);
      var lngDiffInRadians = toRadians(lng2-lng1);

      // The haversine formula
      // 'a' is the square of half the chord length between the points
      var a = Math.sin(latDiffInRadians/2) * Math.sin(latDiffInRadians/2) +
              Math.cos(lat1InRadians) * Math.cos(lat2InRadians) *
              Math.sin(lngDiffInRadians/2) * Math.sin(lngDiffInRadians/2);
      // the angular distance in radians
      var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      // distance between coordinates
      var d = R * c;
      return d/2;
    };

    function updateViewportData(viewport) {
      if (viewport) {
        var boundingboxRadius = computeScale(viewport.getNorthEast(), viewport.getSouthWest());
        maxDistanceInput.value = boundingboxRadius;
        boundingboxInput.value = viewport.toUrlValue();
      } else {
        maxDistanceInput.value = null;
      }
    }

    function isValidPrintableKey(keycode) {
      return keycode == 32 || keycode == 13 || keycode == 8 ||  // spacebar & return key & backspace
        (keycode > 47 && keycode < 112)   || // numbers, letters, numpad keys and some special chars
        (keycode > 185 && keycode < 193) || // ;=,-./` (in order) in standard US layout
        (keycode > 218 && keycode < 223);   // [\]' (in order) in standard US layout
    }

    window.google.maps.event.addListener(autocomplete, 'place_changed', function(){
      var place = autocomplete.getPlace();
      if(place != null) {
        if(place.geometry != null) {
          coordinateInput.value = place.geometry.location.toUrlValue();
          statusInput.value = window.google.maps.places.PlacesServiceStatus.OK;
          locationQueryMade = true;
          updateViewportData(place.geometry.viewport);
          form.submit();
        } else {
          coordinateInput.value = ""; // clear previous coordinates
          // Let's pick first suggestion, if no geometry was returned by autocompletion
          queryPredictions(place.name, handlePredictions);
        }
      }
    });

    // Ensure default events don't fire without correct info
    form.addEventListener('submit', function(e) {
      // If service status is unset and there are no coordinates, do not make search submit
      if(searchInput.value !== "" && !locationQueryMade) {
        e.preventDefault();
        // Submit will be triggered again after call to queryPredictions()
        queryPredictions(searchInput.value, handlePredictions);
      } else if (searchInput.value === "") {
        clearHiddenInputs();
      }
    });

    searchInput.addEventListener('keypress', function(e) {
      // With location search, searchInput should not cause form submit
      if (e.keyCode === 13) {
        e.preventDefault();
      }

      // If searchInput value changes, let's clear derivative hidden fields
      if (isValidPrintableKey(e.keyCode)) {
        locationQueryMade = false;
        clearHiddenInputs();
      }
    });

    var queryPredictions = function(inputString, callback) {
      var autocompleteService = new window.google.maps.places.AutocompleteService();
      sessionToken = new google.maps.places.AutocompleteSessionToken();
      autocompleteService.getPlacePredictions({ input: inputString, sessionToken: sessionToken }, callback);
    };

    var handlePredictions = function(predictions, autocompleteServiceStatus) {
      var serviceStatus = window.google.maps.places.PlacesServiceStatus;

      if(autocompleteServiceStatus === serviceStatus.OK) {
        var map = new window.google.maps.Map(document.createElement('div'));
        var placeService = new window.google.maps.places.PlacesService(map);

        placeService.getDetails({
          placeId: predictions[0].place_id, // first prediction is default
          sessionToken: sessionToken
        }, function(place, placeServiceStatus) {

          if(placeServiceStatus === serviceStatus.OK) {
            coordinateInput.value = place.geometry.location.toUrlValue();
            updateViewportData(place.geometry.viewport);
          }
          // Save received service status for logging
          statusInput.value = placeServiceStatus;
          locationQueryMade = true;
          form.submit();

        });
      } else {
        // Save received service status for logging
        statusInput.value = autocompleteServiceStatus;
        locationQueryMade = true;
        form.submit();
      }
    };
  };
})(window.ST);
