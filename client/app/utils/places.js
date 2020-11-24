/*
 Generic utilities for dealing with Google Maps place objects.
*/

const toRadians = (degrees) => degrees * (Math.PI / 180); // eslint-disable-line no-magic-numbers

/**
 * Calculate the distance between two points.
 *
 * @param {google.maps.LatLng} pointA - first point
 * @param {google.maps.LatLng} pointB - second point
 *
 * @return {Number} distance in kilometers between the given points
 */
const getDistance = (pointA, pointB) => {
  /* eslint-disable no-magic-numbers */

  // Radius in kilometers
  const EARTH_RADIUS = 6371;

  const lat1 = pointA.lat();
  const lat2 = pointB.lat();
  const lng1 = pointA.lng();
  const lng2 = pointB.lng();
  const lat1InRadians = toRadians(lat1);
  const lat2InRadians = toRadians(lat2);
  const latDiffInRadians = toRadians(lat2 - lat1);
  const lngDiffInRadians = toRadians(lng2 - lng1);

  // The haversine formula
  // 'a' is the square of half the chord length between the points
  const a = Math.sin(latDiffInRadians / 2) * Math.sin(latDiffInRadians / 2) +
          Math.cos(lat1InRadians) * Math.cos(lat2InRadians) *
          Math.sin(lngDiffInRadians / 2) * Math.sin(lngDiffInRadians / 2);

  // the angular distance in radians
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  // distance between coordinates
  const d = EARTH_RADIUS * c;

  return d;

  /* eslint-enable no-magic-numbers */
};

/**
 * Get a detailed place object.
 *
 * @param {String} placeId - ID for a place received from the
 * autocomplete service
 *
 * @return {Promise<google.maps.places.PlaceResult>} Promise that
 * resolves to the detailed place, rejects if the request failed
 */
const getDetails = (placeId, sessionToken) => new Promise((resolve, reject) => {
  const serviceStatus = window.google.maps.places.PlacesServiceStatus;
  const el = document.createElement('div');
  const service = new window.google.maps.places.PlacesService(el);
  const request = {
    placeId: placeId, // eslint-disable-line babel/object-shorthand
    fields: ['address_components', 'geometry', 'icon', 'name'],
    sessionToken: sessionToken, // eslint-disable-line babel/object-shorthand
  };

  service.getDetails(request, (place, status) => {
    if (status !== serviceStatus.OK) {
      reject(new Error(`Could not get details for place id "${placeId}"`));
    } else {
      resolve(place);
    }
  });
});


// ================ Public API: ================ //


/**
 * Get the coordinates of a place.
 *
 * @param {google.maps.places.PlaceResult} place - A PlaceResult
 * object received from the autocomplete input or autocomplete service
 *
 * @return {String} a comma separated String ready to use in a URL,
 * null if cannot get the coordinates of the place object
 */
export const coordinates = (place) => {
  if (place && place.geometry && place.geometry.location) {
    // The places autocomplete input might return incomplete place
    // objects, thus the safety check here.
    return place.geometry.location.toUrlValue();
  }
  return null;
};

/**
 * Get the viewport of a place.
 *
 * @param {google.maps.places.PlaceResult} place - A PlaceResult
 * object received from the autocomplete input or autocomplete service
 *
 * @return {String} a comma separated String ready to use in a URL,
 * null if cannot get the viewport of the place object
 */
export const viewport = (place) => {
  if (place && place.geometry && place.geometry.viewport) {
    // As above in coordinates, the places object might be incomplete,
    // but in addition, not all places have the viewport defined
    // (e.g. a bus station).
    return place.geometry.viewport.toUrlValue();
  }
  return null;
};

/**
 * Calculate the maximum search distance for a place.
 *
 * @param {google.maps.places.PlaceResult} place - A PlaceResult
 * object received from the autocomplete input or autocomplete service
 *
 * @return {Number} maximum search distance, null if cannot get the
 * viewport of the place object
 */
export const maxDistance = (place) => {
  if (place && place.geometry && place.geometry.viewport) {
    return getDistance(place.geometry.viewport.getNorthEast(),
                       place.geometry.viewport.getSouthWest()) / 2; // eslint-disable-line no-magic-numbers
  }
  return null;
};

/**
 * Get the place prediction for a location search string.
 *
 * @param {String} location - location query
 *
 * @return {Promise<google.maps.places.PlaceResult>} a Promise that
 * resolves to the first predicted place, rejects if no predictions
 * were found or something failed
 */
export const getPrediction = (location) => new Promise((resolve, reject) => {
  const serviceStatus = window.google.maps.places.PlacesServiceStatus;
  const service = new window.google.maps.places.AutocompleteService();
  const sessionToken = new window.google.maps.places.AutocompleteSessionToken();

  service.getPlacePredictions({ input: location, sessionToken: sessionToken }, // eslint-disable-line babel/object-shorthand
  (predictions, status) => {
    if (status !== serviceStatus.OK) {
      const e = new Error(`Prediction service status not OK: ${status}`);
      e.serviceStatus = status;
      reject(e);
    } else if (predictions.length === 0) {
      reject(new Error(`No predictions found for location "${location}"`));
    } else {
      resolve(getDetails(predictions[0].place_id, sessionToken));
    }
  });
});
