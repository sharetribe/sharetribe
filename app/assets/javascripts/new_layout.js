window.ST = window.ST || {};

(function(module) {

  function check_handler(element) {
   return function(){
      if(!element.prop("checked")){
        element.prop("checked", this.checked);
      }
      element.attr("disabled", this.checked)
    }
  };

  module.initializeNewLayoutManager = function(){
    var $topbar_user = $("#enabled_for_user_topbar_v1");
    var $topbar_community = $("#enabled_for_community_topbar_v1");

    var $user_searchpage = $("#enabled_for_user_searchpage_v1")
        .click(check_handler($topbar_user));
    var $community_searchpage = $("#enabled_for_community_searchpage_v1")
        .click(check_handler($topbar_community));
  };
})(window.ST);
