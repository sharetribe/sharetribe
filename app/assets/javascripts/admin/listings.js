window.ST.initializeListingSearchFormSelector = function() {
  $(".status-select-button").click(function(){
    $(".status-select-dropdown").show();
  });
  function updateSelectedStatus() {
    var v = [];
    $(".status-select-line input:checked").each(function(){
      v.push($(this).parent().text().trim());
    });
    if (v.length == 0) {
      v = [ST.t("admin.communities.listings.status.all")];
    }
    $(".status-select-button, .reset").text(v.join(", "));
  }

  $(".status-select-line").click(function(){
    var status = $(this).data("status");
    if (status == 'all') {
      $(".status-select-dropdown").hide();
    } else {
      var cb = $(this).find("input")[0];
      cb.checked = !cb.checked;
      $(this).toggleClass("selected");
    }
    updateSelectedStatus();
  })
};
