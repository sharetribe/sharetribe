window.ST.initializeListingShapeForm = function(formId) {
  $(formId).validate();

  var priceChanged = function(currentEl) {
    var enabled = currentEl.is(':checked');
    if(enabled) {
      toggleOnlinePaymentEnabled(true);
      toggleUnitsEnabled(true);
    } else {
      toggleOnlinePaymentEnabled(false);
      toggleShippingEnabled(false);
      toggleUnitsEnabled(false);
    }
  };

  var onlinePaymentsChanged = function(currentEl) {
    var enabled = currentEl.is(':checked');
    if(enabled) {
      toggleShippingEnabled(true);
    } else {
      toggleShippingEnabled(false);
    }
  };

  $('#price-enabled').change(function() {
    priceChanged($(this));
  });
  $('#online-payments').change(function() {
    onlinePaymentsChanged($(this));
  });

  var toggleOnlinePaymentEnabled = function(enabled) {
    toggle($("#online-payments"), enabled);
  };

  var toggleShippingEnabled = function(enabled) {
    toggle($("#shipping-enabled"), enabled);

  };

  var toggleUnitsEnabled = function(enabled) {
    toggle($(".js-unit-checkbox"), enabled);
  };

  var toggle = function(el, state) {
    if(state) {
      el.prop('disabled', false);
    } else {
      el.prop('disabled', true);
      el.prop('checked', false);
    }
  };

  // Run once on init
  priceChanged($('#price-enabled'));
  onlinePaymentsChanged($('#online-payments'));

};
