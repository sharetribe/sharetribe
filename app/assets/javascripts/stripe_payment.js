window.ST = window.ST || {};
(function(module) {
  var style = {
    base: {
      color: '#32325d',
      lineHeight: '24px',
      fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      '::placeholder': {
        color: '#aab7c4'
      }
    },
    invalid: {
      color: '#fa755a',
      iconColor: '#fa755a'
    }
  };
  var stripe, spinner;

  var inProgress = false;

  var createCard = function() {
    var elements = stripe.elements();

    var card = elements.create('card', {style: style});
    card.mount('#card-element');
    card.addEventListener('change', function(event) {
      var displayError = document.getElementById('card-errors');
      if (event.error) {
        displayError.textContent = event.error.message;
        displayError.className = 'error';
      } else {
        displayError.textContent = '';
        displayError.className = 'hidden';
      }
    });
    return card;
  };

  var validateForm = function(form) {
    form.validate();
    $('input[stripe-shipping-address]').each(function(){
      $(this).rules('add', { required: true });
    });
    if(!form.valid()) {
      return false;
    }
    return true;
  };

  var handleCreatedPaymentIntent = function(response) {
    var payment = response.stripe_payment_intent;
    if (payment.error) {
      showError(ST.t('error_messages.stripe.generic_error'));
    } else if (payment.requires_action) {
      stripe.handleCardAction(
        payment.client_secret
      ).then(function(result) {
        if (result.error) {
          showError(ST.t('error_messages.stripe.generic_error'));
          $.post(
            payment.failed_intent_path,
            {
              stripe_payment_id: payment.stripe_payment_id,
            },
            function(data) {
              if (!data.success) {
                showError(data.error);
              }
            },
            'json'
          );
        } else {
          // The card action has been handled
          // The PaymentIntent can be confirmed again on the server
          $.post(
            payment.confirm_intent_path,
            {
              stripe_payment_id: payment.stripe_payment_id,
              payment_intent_id: result.paymentIntent.id
            },
            function(data) {
              if (data.success) {
                window.location = data.redirect_url;
              } else {
                showError(data.error);
              }
            },
            'json'
          );
        }
      });
    } else {
      // Show success message
    }
  };

  var showError = function(message) {
    ST.utils.showError(message, 'error');
    ST.transaction.toggleSpinner(spinner, false);
    $('html, body').animate({ scrollTop: $('.flash-notifications').offset().top}, 1000);
    inProgress = false;
  };

  var formSubmit = function(e) {
    var form = $(this),
      formAction = form.attr('action');

    var submitSuccess = function(data, responseStatus) {
      if (data.redirect_url) {
        window.location = data.redirect_url;
        return;
      } else if (data.stripe_payment_intent) {
        handleCreatedPaymentIntent(data);
      } else if (data.error) {
        ST.transaction.toggleSpinner(spinner, true);
        showError(data.error);
      } else if (data.error_msg) {
        ST.transaction.toggleSpinner(spinner, true);
        showError(data.error_msg);
      }
    };
    $.post(formAction, form.serialize(), submitSuccess, 'json');
  };


  var initIntent = function(options){
    stripe = Stripe(options.publishable_key);
    var card = createCard();
    var form = $("#transaction-form");

    form.on('stripe-submit', formSubmit);
    spinner = form.find('.paypal-button-loading-img');
    $("#send-add-card").on('click', function(ev) {
      ev.preventDefault();
      if (inProgress) {
        return false;
      } else {
        if (!validateForm(form)) {
          return false;
        }

        inProgress = true;

        ST.transaction.toggleSpinner(spinner, true);
        stripe.createPaymentMethod('card', card, {}).then(function(result) {
          if (result.error) {
            inProgress = false;
            showError(ST.t('error_messages.stripe.generic_error'));
          } else {
            // Otherwise send paymentMethod.id to server
            var existingInput = $('#stripe_payment_method_id');
            if (existingInput.length > 0) {
              existingInput.val(result.paymentMethod.id);
            } else {
              var input = $('<input/>', {type: 'hidden', name: 'stripe_payment_method_id', id: 'stripe_payment_method_id', value: result.paymentMethod.id});
              form.append(input);
            }
            $('#payment_type').val('stripe');
            if(form.valid()) {
              form.trigger('stripe-submit');
            }
          }
        });
      }
    });
  };

  module.StripePayment = {
    initIntent: initIntent,
  };
})(window.ST);
