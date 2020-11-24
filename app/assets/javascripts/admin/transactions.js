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
window.ST.initializeTransactionSearchFormSelector = function() {
  $(".status-select-button").click(function(){
    $(".status-select-dropdown").show();
    setTimeout(function() { document.addEventListener('mousedown', outsideClickListener);}, 300);
  });
  function updateSelectedStatus() {
    var v = [];
    $(".status-select-line input:checked").each(function(){
      v.push($(this).parent().text().trim());
    });
    if (v.length == 0) {
      v = [ST.t("admin.communities.transactions.status_filter.all")];
    } else {
      v = [ST.t("admin.communities.transactions.status_filter.selected_js") + v.length];
    }
    $(".status-select-button, .reset").text(v.join(", "));
  }

  $(".status-select-line").click(function(){
    var status = $(this).data("status");
    if (status == 'all') {
      $(".status-select-dropdown").hide();
      document.removeEventListener('mousedown', outsideClickListener);
    } else {
      var cb = $(this).find("input")[0];
      cb.checked = !cb.checked;
      $(this).toggleClass("selected");
    }
    updateSelectedStatus();
  });
  function outsideClickListener(evt) {
    if (!$(evt.target).closest(".status-select-line").length) {
      $(".status-select-dropdown").hide();
      document.removeEventListener('mousedown', outsideClickListener);
    }
  }
};

