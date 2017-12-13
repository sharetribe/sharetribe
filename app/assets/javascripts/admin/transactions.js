window.ST = window.ST || {};
window.ST.initializeExportPolling = function (url, element, message) { 
  var spinner = new Image();
  spinner.align = 'center';
  spinner.src = "https://s3.amazonaws.com/sharetribe/assets/ajax-loader-grey.gif";
  var span = $("<span/>");
  var oldHtml = $(element).html();
  span.html(message);
  span.prepend(spinner);
  $(element).html(span);
  ST.utils.baconStreamFromAjaxPolling(
    {url: url}, 
    function(pollingResult) {
        return pollingResult.status == 'finished';
      }
  ).onValue(function (val) { 
    $(element).html(oldHtml);
    window.location = val.url;
  });
};

