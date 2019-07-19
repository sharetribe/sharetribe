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
  var stripe;

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

  var initCharge = function(options){
    stripe = Stripe(options.publishable_key);

    $("#shipping_address_country_code").change(function(){
      if($(this).val() == 'US') $(".us-only").show(); else $(".us-only").hide();
    });
    $("#shipping_address_country_code").trigger("change");

    var card = createCard();

    $("#send-add-card").on('click', function(event) {
      event.preventDefault();
      var form = $("#transaction-form");
      if (!validateForm(form)) {
        return false;
      }

      stripe.createToken(card).then(function(result) {
        var errorElement = document.getElementById('card-errors');
        if (result.error) {
          errorElement.textContent = result.error.message;
          errorElement.className = 'error';
        } else {
          errorElement.className = 'hidden';
          var input = $("<input/>", {type: "hidden", name: "stripe_token", value: result.token.id});
          form.append(input);
          $("#payment_type").val("stripe");
          if(form.valid()) {
            form.submit();
          }
        }
      });
    });
  };

  var handleCreatedPaymentIntent = function(response) {
    var payment = response.stripe_payment_intent;
    if (payment.error) {
      // Show error from server on payment form
    } else if (payment.requires_action) {
      stripe.handleCardAction(
        payment.client_secret
      ).then(function(result) {
        if (result.error) {
          ST.utils.showError('Stripe cannot handleCardAction', 'error');
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
                ST.utils.showError(data.error, 'error');
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


  var initIntent = function(options){
    stripe = Stripe(options.publishable_key);
    var card = createCard();

    $("#send-add-card").on('click', function(ev) {
      event.preventDefault();
      var form = $("#transaction-form");
      if (!validateForm(form)) {
        return false;
      }

      stripe.createPaymentMethod('card', card, {}).then(function(result) {
        if (result.error) {
          // Show error in payment form
        } else {
          // Otherwise send paymentMethod.id to server
          var input = $('<input/>', {type: 'hidden', name: 'stripe_payment_method_id', value: result.paymentMethod.id});
          form.append(input);
          $('#payment_type').val('stripe');
          if(form.valid()) {
            form.trigger('submit');
          }
        }
      });
    });
  };

  module.StripePayment = {
    initCharge: initCharge,
    initIntent: initIntent,
    handleCreatedPaymentIntent: handleCreatedPaymentIntent
  };
})(window.ST);
