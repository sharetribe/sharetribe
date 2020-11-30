window.ST = window.ST || {};

window.ST.initializeListingShapeForm = function(formId) {
    $(formId).validate({
        errorPlacement: function(error, element) {
            if (element.hasClass("js-custom-unit-kind-radio")) {
                error.appendTo($(".js-custom-unit-kind-container"));
            } else if ($(element).parents('.multiple-languages-input').length) {
                $(error).insertAfter($(element).parents('.multiple-languages-input'));
                error.addClass('form-text');
                $(element).parents('.multiple-languages-input').find('.input-group-text').addClass('attention');
            } else {
                error.insertAfter(element);
            }
        }
    });

    var initializeState = function(state) {
        toggleOnlinePaymentEnabled(state.priceEnabled);
        toggleUnitsEnabled(state.priceEnabled && !state.availabilityEnabled);
        toggleShippingEnabled(state.onlinePaymentsEnabled);
        toggleAvailabilityEnabled(state.onlinePaymentsEnabled);
        toggleAvailabilityUnitsEnabled(state.availabilityEnabled);
    };

    var isChecked = function(el) {
        return el.is(':checked');
    };

    var isPriceEnabled = isChecked;
    var isOnlinePaymentsEnabled = isChecked;
    var isAvailabilityEnabled = isChecked;

    var priceChanged = function(currentEl) {
        var enabled = isPriceEnabled(currentEl);

        if(enabled) {
            toggleOnlinePaymentEnabled(true);
            toggleUnitsEnabled(true);
        } else {
            toggleOnlinePaymentEnabled(false);
            toggleShippingEnabled(false);
            toggleUnitsEnabled(false);
            toggleAvailabilityEnabled(false);
            toggleAvailabilityUnitsEnabled(false);
        }
    };

    var onlinePaymentsChanged = function(currentEl) {
        var enabled = isOnlinePaymentsEnabled(currentEl);

        if(enabled) {
            toggleAvailabilityEnabled(true);
            toggleShippingEnabled(true);
            toggleUnitsEnabled(true);
        } else {
            toggleAvailabilityEnabled(false);
            toggleAvailabilityUnitsEnabled(false);
            toggleShippingEnabled(false);
            toggleUnitsEnabled(true);
        }
    };

    var availabilityChanged = function(currentEl) {
        var enabled = isAvailabilityEnabled(currentEl);

        if(enabled) {
            toggleAvailabilityUnitsEnabled(true);
            toggleUnitsEnabled(false);
        } else {
            toggleAvailabilityUnitsEnabled(false)
            toggleUnitsEnabled(true);
        }
    }

    var toggleOnlinePaymentEnabled = function(enabled) {
        toggleCheckboxEnabled($(".js-online-payments"), enabled);
        toggleLabelEnabled($(".js-online-payments-label"), enabled);
    };

    var toggleShippingEnabled = function(enabled) {
        toggleCheckboxEnabled($(".js-shipping-enabled"), enabled);
        toggleLabelEnabled($(".js-shipping-enabled-label"), enabled);
    };

    var toggleUnitsEnabled = function(enabled) {
        toggleCheckboxEnabled($(".js-unit-checkbox"), enabled);
        toggleLabelEnabled($(".js-unit-label"), enabled);
        toggleInfoEnabled($('.js-pricing-units-info'), enabled);
        toggleCustomUnitsEnabled(enabled);
    };

    var toggleCustomUnitsEnabled = function(enabled) {
        toggleLabelEnabled($(".js-listing-shape-add-custom-unit-link"), enabled);
        toggleInputEnabled($('.js-custom-unit input'), enabled);
    };

    var toggleAvailabilityEnabled = function(enabled) {
        toggleCheckboxEnabled($(".js-availability"), enabled);
        toggleLabelEnabled($(".js-availability-label"), enabled);
    };

    var toggleAvailabilityUnitsEnabled = function(enabled) {
        toggleRadioEnabled($(".js-availability-unit"), enabled);
        toggleLabelEnabled($(".js-availability-unit-label"), enabled);
        toggleInfoEnabled($('.js-pricing-units-disabled-info'), enabled)
    };

    var removeCustomUnit = function() {
        var index = $(this).data("customunitindex");
        if (typeof index !== "undefined") {
            $('.js-custom-unit-' + index).remove();
        }
    };

    var closeCustomUnitForm = function() {
        this.parentElement.remove();
    };

    var toggleCheckboxEnabled = function(el, state) {
        toggleInputEnabled(el, state);

        if (!state) {
            el.prop('checked', false);
        }
    };

    var toggleInputEnabled = function(el, state) {
        if(state) {
            el.prop('disabled', false);
            $('.hidden-unit-div input:hidden').prop('disabled', false);
        } else {
            el.prop('disabled', true);
            $('.hidden-unit-div input:hidden').prop('disabled', true);
        }
    };

    var toggleRadioEnabled = function(el, state) {
        if(state) {
            el.prop('disabled', false);

            // Check the first one if none of the radiobuttons is checked
            if (!el.is(":checked")) {
                el.first().prop('checked', true);
            }
        } else {
            el.prop('disabled', true);
            el.prop('checked', false);
        }
    };

    var toggleInfoEnabled = function(el, state) {
        if (state) {
            el.show();
        } else {
            el.hide();
        }
    };

    var toggleLabelEnabled = function(el, state) {
        el.toggleClass('opacity_035', !state);
    };

    $('.js-price-enabled').change(function() {
        priceChanged($(this));
    });
    $('.js-online-payments').change(function() {
        onlinePaymentsChanged($(this));
    });
    $('.js-availability').click(function() {
        availabilityChanged($(this));
    });

    $('.js-listing-shape-close-custom-unit-form').click(closeCustomUnitForm);
    $('.js-remove-custom-unit').click(removeCustomUnit);

    // Run once on init
    initializeState({
        priceEnabled: isPriceEnabled($('.js-price-enabled')),
        onlinePaymentsEnabled: isOnlinePaymentsEnabled($('.js-online-payments')),
        availabilityEnabled: isAvailabilityEnabled($('.js-availability')),
    })
};
