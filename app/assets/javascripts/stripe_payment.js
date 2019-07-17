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

  var init = function(options){
    var stripe = Stripe(options.publishable_key);
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

    $("#send-add-card").on('click', function(event) {
      event.preventDefault();
      var form = $("#transaction-form");
      form.validate();
      $('input[stripe-shipping-address]').each(function(){
        $(this).rules('add', { required: true });
      });
      if(!form.valid()) {
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

  module.StripePayment = {
    init: init
  };
})(window.ST);
