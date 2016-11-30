function initialize_merchant_form() {
  var form_id = "#new_merchant";
  //name_required = (name_required == 1) ? true : false
  $(form_id).validate({
    rules: {
      "first_name": {required: true},
      "last_name": {required: true},
      "email": {required: true, email: true},
      "street_address": {required: true, minlength: 10, maxlength: 20},
      "postal_code": {required: true, number: true, maxlength: 6},
      "business_name": {required: true},
      "tax_id": {required: true},
      "account_number": {required: true, number: true},
      "tos_accepted": {required: true}
    },
    messages: {
      'tos_accepted': {
          required: "Merchant Terms of Service must be checked"
      },
      'account_number': {
          required: "Your account number must be provided"
      }
    }
  });
}

function paymentForm() {
  if (typeof gon !== 'undefined') {
    return braintree.setup(gon.client_token, 'dropin', {
      container: 'braintreeDropin',
      onPaymentMethodReceived: function (payload) {
        console.log(payload)
        $("#payment_method_type").val(payload.type)
        $("#payment_method_nonce").val(payload.nonce)
        setTimeout(function () {
          $("form#payment-form").submit()
        }, 1000)
      },
      onError: function() {
        if (obj.type == 'VALIDATION') {
          console.log(obj.details.invalidFields)
        }

      },
      paypal: {
        singleUse: false,
        currency: 'USD',
        button: {
          type: 'checkout'
        }
      }
    });
  }
};

$(document).ready(function() {
  initialize_merchant_form()
  paymentForm()
})
