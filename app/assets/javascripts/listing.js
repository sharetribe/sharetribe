window.ST = window.ST || {};

(function(module) {
  var initGoogleMap = function(options) {
    if (!window.google) {
      return;
    }
    var listing_location = options.listing_location;
    var center = new google.maps.LatLng(listing_location.latitude, listing_location.longitude);
    var mapOptions = {
      zoom: 12,
      streetViewControl: false,
      mapTypeControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      zoomControl: true,
    };
    var map = new google.maps.Map(document.getElementById('dynamic-map-canvas'), mapOptions);

    map.setCenter(center);
    var circle = new google.maps.Circle({
      strokeColor: '#C0392B',
      strokeOpacity: 0.3,
      strokeWeight: 1,
      fillColor: '#C0392B',
      fillOpacity: 0.2,
      map: map,
      center: center,
      radius: 500,
      clickable: false
    });
  };

  var initFuzzyLocation = function(options) {
    $(document).ready(function() {
      initGoogleMap(options);
      $('#static-map').on('click', function() {
        $(this).hide();
        $('#dynamic-map-canvas').removeClass('hidden');
      });
    });
  };

  module.listing = function(options) {
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
    if (options.fuzzy_location) {
      initFuzzyLocation(options);
    }
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

  module.initializeShippingPriceTotal = function(currencyOpts, quantityInputSelector, shippingPriceSelector){
    var $quantityInput = $(quantityInputSelector);
    var $shippingPriceElements = $(shippingPriceSelector);

    var updateShippingPrice = function() {
      $shippingPriceElements.each(function(index, shippingPriceElement) {
        var $priceEl = $(shippingPriceElement);
        var shippingPriceCents = $priceEl.data('shipping-price') || 0;
        var perAdditionalCents = $priceEl.data('per-additional') || 0;
        var quantity = parseInt($quantityInput.val() || 0);
        var additionalCount = Math.max(0, quantity - 1);

        // To avoid floating point issues, do calculations in cents
        var newShippingPrice = shippingPriceCents + perAdditionalCents * additionalCount;
        var priceForDisplay = ST.paymentMath.displayMoney(newShippingPrice,
                                                          currencyOpts.symbol,
                                                          currencyOpts.digits,
                                                          currencyOpts.format,
                                                          currencyOpts.separator,
                                                          currencyOpts.delimiter)
        $priceEl.text(priceForDisplay);
      });
    };

    $quantityInput.on("keyup change", updateShippingPrice); // change for up and down arrows
    updateShippingPrice();
  };

})(window.ST);
