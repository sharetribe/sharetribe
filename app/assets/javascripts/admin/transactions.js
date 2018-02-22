window.ST = window.ST || {};
window.ST.initializeExportPolling = function (options) {
  var element = $('#export-as-csv');
  var oldHtml = $(element).html();
  element.html(options.loading);
  ST.utils.baconStreamFromAjaxPolling(
    {url: options.pollingUrl},
    function(pollingResult) {
      return pollingResult.status == 'finished';
    }
  ).onValue(function (val) {
    element.html(oldHtml);
    downloadURI(val.url, 'export.csv');
  });

  var downloadURI = function (uri, name) {
    var link = document.createElement('a');
    link.download = name;
    link.href = uri;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    link = null;
  };
};

