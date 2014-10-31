window.ST = window.ST || {};

(function(module) {

  module.initializePayPalAccountForm = function(formId) {
    var form = $('#'+formId);
    var spinner = new Image();
    spinner.src = "https://s3.amazonaws.com/sharetribe/assets/ajax-loader-grey.gif";
    spinner.className = "send-button-loading-img";

    form.validate({
      submitHandler: function(form) {
        var $form = $(form);
        var $sendButton = $form.find(".send_button");
        if(!$sendButton.hasClass("send-button-loading")) {
          $form.find(".send-button-wrapper").append(spinner);
          $sendButton.addClass("send-button-loading").blur();
          form.submit();
        }
      }
    });
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
          number_max: commissionRange[1]
        },
        "paypal_preferences_form[minimum_listing_price]": {
          required: true,
          number_min: minCommission
        }
      }
    });
  };

})(window.ST);
