window.ST = window.ST || {};

(function(module) {


  module.initializePayPalAccountForm = function(button_id, action) {
    var button = $('#'+button_id);
    var spinner = new Image();
    spinner.src = "https://s3.amazonaws.com/sharetribe/assets/ajax-loader-grey.gif";
    spinner.className = "send-button-loading-img";

    console.log("Does this workL");
    button.click(function(){
      $(".send-button-wrapper").append(spinner);
      button.addClass("send-button-loading").blur();

      $.ajax({
        type: 'GET',
        url: action,
        success: function(response){
          $(".send-button-wrapper").before(response.redirect_message);
          window.location = response.redirect_url;
        }
      });

    })
  };

  module.initializePayPalPreferencesForm = function(formId, commissionRange, minCommission) {
    var form = $('#' + formId);

    form.validate({
      errorPlacement: function(error, element) {
        error.appendTo(element.parent());
      },
      rules: {
        "paypal_preferences_form[commission_from_seller]": {
          required: true,
          number_min: commissionRange[0],
          number_max: commissionRange[1],
          number_no_decimals: true
        },
        "paypal_preferences_form[minimum_listing_price]": {
          required: true,
          number_min: minCommission
        },
        "paypal_preferences_form[minimum_transaction_fee]": {
          required: true,
          number_min: 0
        }
      }
    });
  };

})(window.ST);
