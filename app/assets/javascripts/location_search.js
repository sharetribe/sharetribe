window.ST = window.ST || {};

(function(module) {

  module.initializeLocationSearch = function(minimumDistanceMax) {
    var searchInput = document.getElementById('q');
    var statusInput = document.getElementById('ls');
    var coordinateInput = document.getElementById('lc');
    var boundingboxInput = document.getElementById('boundingbox');
    var maxDistanceInput = document.getElementById('distance_max');
    var homepageForm = document.getElementById('homepage-filters');
    var autocomplete = new window.google.maps.places.Autocomplete(searchInput, { bounds: { north: -90, east: -180, south: 90, west: 180 } });
    autocomplete.setTypes(['geocode']);

    boundingboxInput.value = null;

    function toRadians(degrees) {
      return degrees * (3.1415/180);
    }

    function computeScale(a, b) {
      var R = 6371; // Earth's radius in km

      var lat1 = a.lat();
      var lat2 = b.lat();
      var lng1 = a.lng();
      var lng2 = b.lng();
      var φ1 = toRadians(lat1);
      var φ2 = toRadians(lat2);
      var Δφ = toRadians(lat2-lat1);
      var Δλ = toRadians(lng2-lng1);

      var a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
      var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

      var d = R * c;
      return d/2;
    };

    function updateViewportData(viewport) {
      if (viewport) {
        var boundingboxRadius = computeScale(viewport.getNorthEast(), viewport.getSouthWest());
        maxDistanceInput.value = boundingboxRadius;
        boundingboxInput.value = viewport.toUrlValue();
      } else {
        maxDistanceInput.value = minimumDistanceMax;
      }
    }

    window.google.maps.event.addListener(autocomplete, 'place_changed', function(){
      var place = autocomplete.getPlace();
      if(place != null) {
        if(place.geometry != null) {
          coordinateInput.value = place.geometry.location.toUrlValue();
          statusInput.value = window.google.maps.places.PlacesServiceStatus.OK;
          updateViewportData(place.geometry.viewport);
          homepageForm.submit();
        } else {
          coordinateInput.value = ""; // clear previous coordinates
          // Let's pick first suggestion, if no geometry was returned by autocompletion
          queryPredictions(place.name, handlePredictions);
        }
      }
    });

    // Ensure default events don't fire without correct info
    homepageForm.addEventListener('submit', function(e) {
      // If service status is unset and there are no coordinates, do not make search submit
      if(statusInput.value === "" && coordinateInput.value === "" && searchInput.value !== "") {
        e.preventDefault();
        // Submit will be triggered again after call to queryPredictions()
        queryPredictions(searchInput.value, handlePredictions);
      }
    });

    // With location search searchInput should not cause form submit
    searchInput.addEventListener('keypress', function(e) {
      if (e.keyCode === 13) {
        e.preventDefault();
      }
    });

    var queryPredictions = function(inputString, callback) {
      var autocompleteService = new window.google.maps.places.AutocompleteService();
      autocompleteService.getQueryPredictions({ input: inputString }, callback);
    };

    var handlePredictions = function(predictions, autocompleteServiceStatus) {
      var serviceStatus = window.google.maps.places.PlacesServiceStatus;

      if(autocompleteServiceStatus === serviceStatus.OK) {
        var map = new window.google.maps.Map(document.createElement('div'));
        var placeService = new window.google.maps.places.PlacesService(map);

        placeService.getDetails({
          placeId: predictions[0].place_id // first prediction is default
        }, function(place, placeServiceStatus) {

          if(placeServiceStatus === serviceStatus.OK) {
            coordinateInput.value = place.geometry.location.toUrlValue();
            updateViewportData(place.geometry.viewport);
          }
          // Save received service status for logging
          statusInput.value = placeServiceStatus;
          homepageForm.submit();

        });
      } else {
        // Save received service status for logging
        statusInput.value = autocompleteServiceStatus;
        homepageForm.submit();
      }
    };


  };
})(window.ST);
