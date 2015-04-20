window.ST = window.ST || {};

(function(module) {
  module.listing = function() {
    $('#add-to-updates-email').on('click', function() {
      var text = $(this).find('#add-to-updates-email-text');
      var actionLoading = text.data('action-loading');
      var actionSuccess = text.data('action-success');
      var actionError = text.data('action-error');
      var url = $(this).attr('href');

      text.html(actionLoading);

      $.ajax({
        url: url,
        type: "PUT",
      }).done(function() {
        text.html(actionSuccess);
      }).fail(function() {
        text.html(actionError);
      });
    });
  };

  module.initializeQuantityValidation = function(opts) {
    jQuery.validator.addMethod(
      "positiveIntegers",
      function(value) {
        return (value % 1) === 0 && value > 0;
      },
      jQuery.validator.format(opts.errorMessage)
    );

    // add rule to input
    $('#'+opts.input).rules("add", {
      positiveIntegers: true
    });
  };

  module.initializeShippingPriceTotal = function(quantityInputSelector, shippingPriceSelector){
    var quantityInput = $(quantityInputSelector);
    var shippingPriceElements = $(shippingPriceSelector);

    var updateShippingPrice = function() {
      shippingPriceElements.each(function(index, shippingPriceElement) {
        var shippingPrice = $(shippingPriceElement).data('shipping-price');
        var perAdditional = $(shippingPriceElement).data('per-additional');
        var hasPoint = shippingPrice.indexOf(',') >= 0;

        if(hasPoint) {
          shippingPrice = shippingPrice.split(',').join('.');
          perAdditional = perAdditional.split(',').join('.');
        }

        var newShippingPrice = parseFloat(shippingPrice);
        if(perAdditional != null) {
          newShippingPrice += parseFloat(perAdditional) * ( parseInt(quantityInput.val()) - 1 );
        }

        var shippingPriceString = hasPoint ? newShippingPrice.toFixed(2).toString().split('.').join(',') : newShippingPrice.toFixed(2);
        $(shippingPriceElement).text(shippingPriceString);
      });
    };

    quantityInput.on("keyup", updateShippingPrice);
    updateShippingPrice();
  };

})(window.ST);
