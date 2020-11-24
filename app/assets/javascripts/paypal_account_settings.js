window.ST = window.ST || {};

(function(module) {


  module.initializeNewPaypalAccountHandler = function(linkId, action, redirectMessageSelector) {
    var $link = $('#'+linkId);
    var spinner = new Image();
    spinner.src = "https://s3.amazonaws.com/sharetribe/assets/ajax-loader-grey.gif";
    spinner.className = "send-button-loading-img";

    $link.click(function(){
      $link.after(spinner);
      $link.addClass("send-button-loading").blur();

      $.ajax({
        type: 'GET',
        url: action,
        success: function(response){
          var $redirectLink = $('#' + linkId + '_redirect');
          $redirectLink.attr('href', response.redirect_url);
          $(redirectMessageSelector).removeClass('hidden');
          window.location = response.redirect_url;
        }
      });

    });
  };

  module.initializePayPalPreferencesForm = function(formId, commissionRange) {
    var $form = $('#' + formId);
    var $currency = $form.find('#payment_preferences_form_marketplace_currency');
    var $currencyLabels = $form.find('.paypal-preferences-currency-label');
    var $warning = $form.find('.paypal-currency-change-warning-text');

    $currency.on('change', function() {
      $currencyLabels.text($currency.val());
      $warning.show();
    });

    $form.validate({
      errorPlacement: function(error, element) {
        error.appendTo(element.parent());
      },
      rules: {
        "payment_preferences_form[commission_from_seller]": {
          required: true,
          number_min: commissionRange[0],
          number_max: commissionRange[1],
          number_no_decimals: true
        },
        "payment_preferences_form[minimum_listing_price]": {
          required: true
        },
        "payment_preferences_form[minimum_transaction_fee]": {
          required: true,
          number_min: 0
        }
      }
    });
  };

})(window.ST);
