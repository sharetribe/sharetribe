window.ST = window.ST || {};

/**
  Ajax request status indicator

  Give `ajaxRequest` and `ajaxResponse` and get back four streams which reflect
  the status of the request (loading, success, error, idle)

  Usage:

  var ajaxResponse = ajaxRequest.ajax();
  var status = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  status.loading.onValue(function() { ...show loading })
  status.success.onValue(function() { ...show success message })
  status.error.onValue(function() { ...show error message })
  status.idle.onValue(function() { ...show hide previous messages })
*/
window.ST.ajaxStatusIndicator = function(ajaxRequest, ajaxResponse, minLoadingTime, resultHideTime) {
  minLoadingTime = minLoadingTime || 1000;
  resultHideTime = resultHideTime || 3000;

  var ajaxResponseStatus = ajaxResponse
    .map(function() { return true; })
    .mapError(function() { return false; });

  var canHideLoadingMessage = ajaxRequest.flatMapLatest(function() {
    return Bacon.later(minLoadingTime, true).toProperty(false);
  }).toProperty(false);

  var isTrue = function(value) { return value === true; };

  return {
    loading: ajaxRequest,
    success: canHideLoadingMessage.and(ajaxResponseStatus).filter(isTrue),
    error: canHideLoadingMessage.and(ajaxResponseStatus.not()).filter(isTrue),
    idle: canHideLoadingMessage.and(ajaxResponseStatus).debounce(resultHideTime)
  };
};
