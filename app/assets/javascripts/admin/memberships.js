window.ST = window.ST || {};
(function(module) {
  function updateSelectedStatus() {
    var v = [];
    $(".status-select-line input:checked").each(function(){
      v.push($(this).parent().text().trim());
    });
    if (v.length === 0) {
      v = [ST.t("admin.communities.manage_members.status_filter.all")];
    } else {
      v = [ST.t("admin.communities.manage_members.status_filter.selected_js") + v.length];
    }
    $(".status-select-button, .reset").text(v.join(", "));
  }

  function outsideClickListener(evt) {
    if (!$(evt.target).closest(".status-select-line").length) {
      $(".status-select-dropdown").hide();
      document.removeEventListener('mousedown', outsideClickListener);
    }
  }

  var init = function() {
    $(".status-select-button").click(function(){
      $(".status-select-dropdown").show();
      setTimeout(function() { document.addEventListener('mousedown', outsideClickListener);}, 300);
    });
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
  };

  module.Memberships = {
    init: init,
  };
})(window.ST);
