function initialize_paypal_form() {
  var form_id = "#new_paypal_merchant";
  $(form_id).validate({
    rules: {
      "business_email": {required: true, email: true},
    }
  });
}

$(document).ready(function() {
  initialize_paypal_form()
})
