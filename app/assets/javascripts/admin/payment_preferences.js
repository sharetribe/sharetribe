window.ST = window.ST || {};

(function(module) {

  var initPaymentTabs = function(min_price, fee_error_message) {
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
        rules: {
          "payment_preferences_form[commission_from_seller]": {
            required: true,
            number_min: 0,
            number_max: 100,
            number_no_decimals: true
          },
          "payment_preferences_form[minimum_transaction_fee]": {
            required: true,
            number_max: min_price,
            number_min: 0,
          }
        },
        messages: {
          "payment_preferences_form[minimum_transaction_fee]": fee_error_message
        }
      });
    })
  };
  module.initPaymentTabs = initPaymentTabs;

})(window.ST);
