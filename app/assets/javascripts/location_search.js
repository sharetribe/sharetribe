window.ST = window.ST || {};

(function(module) {

  module.initializeLocationSearch = function() {
    var searchInput = document.getElementById('q');
    var statusInput = document.getElementById('ls');
    var coordinateInput = document.getElementById('lc');
    var boundingboxInput = document.getElementById('boundingbox');
    var homepageForm = document.getElementById('homepage-filters');
    var autocomplete = new window.google.maps.places.Autocomplete(searchInput, { bounds: { north: -90, east: -180, south: 90, west: 180 } });
    autocomplete.setTypes(['geocode']);

    boundingboxInput.value = null;

    window.google.maps.event.addListener(autocomplete, 'place_changed', function(){
      var place = autocomplete.getPlace();
      if(place != null) {
        if(place.geometry != null) {
          coordinateInput.value = place.geometry.location.toUrlValue();
          statusInput.value = window.google.maps.places.PlacesServiceStatus.OK;
          if (place.geometry.viewport) {
            boundingboxInput.value = place.geometry.viewport.toUrlValue();
          }
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
            if (place.geometry.viewport) {
              boundingboxInput.value = place.geometry.viewport.toUrlValue();
            }
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
