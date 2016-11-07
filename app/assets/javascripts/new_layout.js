window.ST = window.ST || {};

(function(module) {

  function check_handler(element) {
   return function(){
      if (!element.prop("checked")){
        element.prop("checked", this.checked);
      }
     element.attr("disabled", this.checked);
    }
  };

  // Disables and enables required checkboxes for parent flags
  module.initializeNewLayoutManager = function(feature_rels){
    Object.keys(feature_rels).forEach(function(key,index) {
      var $parent_for_user = $("#enabled_for_user_" + key);
      var $required_for_user = $("#enabled_for_user_" + feature_rels[key]);

      var $parent_for_community = $("#enabled_for_community_" + key);
      var $required_for_community = $("#enabled_for_community_" + feature_rels[key]);

      $parent_for_user.click(check_handler($required_for_user));
      $parent_for_community.click(check_handler($required_for_community));
    });
  };
})(window.ST);
