window.ST = window.ST || {};

(function(module) {
  var init = function() {
    var fieldMap = $(".footer-social-container").map(function(id, entry) {
      return {
        id: $(entry).data("field-id"),
        element: $(entry),
        up: $(".menu-link-action-up", entry),
        down: $(".menu-link-action-down", entry)
      };
    }).get();

    var orderManager = window.ST.orderManager(fieldMap);

    var submitHandler = function(form) {
      var index = 0;
      $(".sort-priority").each(function(){
        $(this).val(index);
        index++;
      });
      form.submit();
    };

    $("#footer-social-form").validate({submitHandler: submitHandler});
  };

  module.FooterSocial = {
    init: init
  };
})(window.ST);
