window.ST = window.ST || {};
(function(module) {
  var stripeApi;

  var prepareData = function(options) {
    var type, data, first_name, last_name;

    if ($('#stripe_account_form_onboarding_business_type_company').prop('checked')) {
      type = 'company';
    } else {
      type = 'individual';
    }

    data = {
      business_type: type,
      tos_shown_and_accepted: true
    };

    if (type === 'individual') {
      first_name = $('#stripe_account_form_onboarding_first_name').value;
      last_name = $('#stripe_account_form_onboarding_last_name').value;

      $.extend(data, { individual: { first_name: first_name, last_name: last_name }});
    }

    return data;
  };

  var init = function(options) {
    stripeApi = Stripe(options.api_publishable_key);
    const myForm = document.querySelector('#stripe-account-form');
    const submit_button = $('#submit_stripe_form');
    myForm.addEventListener('submit', handleForm);

    async function handleForm(event) {
      event.preventDefault();
      submit_button.prop('disabled', true);

      var data = prepareData(options),
          accountResult = await stripeApi.createToken('account', data);

      if (accountResult.token) {
        $('#stripe_account_form_onboarding_token').val(accountResult.token.id);
        myForm.submit();
      } else {
        submit_button.prop('disabled', false);
        alert(accountResult.error.message);
      }
    }

    var select_country = $('#stripe_account_form_onboarding_address_country'),
        country_dependent = $('.country-dependent');

    select_country.on('change', function(){
      var country = $(this).val(),
          stripe_link = $("#stripe-terms-link");
      if (country) {
        country_dependent.show();
        if (stripe_link.size() > 0) {
          stripe_link.attr('href', stripe_link.data("terms-url").replace(/COUNTRY/, country.toLowerCase()));
        }
      } else {
        country_dependent.hide();
      }
    });

    if ($('#stripe_account_form_onboarding_address_country option:selected')) {
      select_country.trigger('change');
    } else {
      country_dependent.hide();
    }
  };

  module.StripeBankFormOnboarding = {
    init: init
  };
})(window.ST);
