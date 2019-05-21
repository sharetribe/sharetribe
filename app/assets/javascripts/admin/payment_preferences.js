window.ST = window.ST || {};

(function(module) {

  var initPaymentTabs = function() {
    $(".tab-link").click(function(){
      $(".tab-link").removeClass("active");
      $(this).addClass("active");
      $(".tab-content").hide();
      $("#"+$(this).data('tab')).show();
      return false;
    });

    $("#config_paypal_toggle").click(function(){
      $(".connect-row").hide();
      $(".payment-tabs").show();
      $(".tab-link.paypal").click();
      return false;
    });

    $("#config_stripe_toggle").click(function(){
      $(".connect-row").hide();
      $(".payment-tabs").show();
      $(".tab-link.stripe").click();
      return false;
    });

    $("#transaction_preferences_form_paypal, #transaction_preferences_form_stripe").each(function() {
      $(this).validate({
        errorPlacement: function(error, element) {
          error.appendTo(element.parent());
        },
      });
    });
  };
  module.initPaymentTabs = initPaymentTabs;

})(window.ST);
