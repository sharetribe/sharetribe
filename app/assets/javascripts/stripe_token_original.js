// contains async-await
var stripeToken = async function(options, callback) {
  var country = getValue('address_country'),
    firstName = getValue('first_name'),
    lastName = getValue('last_name');

  var data = {
    legal_entity: {
      type: 'individual',
    },

    tos_shown_and_accepted: true
  };

  var address = {
    address: {
      city: getValue('address_city'),
      state: getValue('address_state'),
      country: getValue('address_country'),
      postal_code: getValue('address_postal_code'),
      line1: getValue('address_line1'),
    }
  };

  var person = {
    first_name: firstName,
    last_name: lastName,
    dob: {
      day: getValue('birth_date(3i)', 'int'),
      month: getValue('birth_date(2i)', 'int'),
      year: getValue('birth_date(1i)', 'int'),
    },
    personal_id_number: ['US', 'CA', 'HK', 'SG'].includes(country) ? getValue('personal_id_number') : null
  };

  if (options.update) {
    $.extend(data.legal_entity, address);
  } else {
    $.extend(data.legal_entity, address, person);
  }

  var verificationEl = $('#stripe_account_form_document'),
    verify = verificationEl.length > 0,
    verification = null;
  if (verify) {
    var fileForm = new FormData();
    fileForm.append('file', verificationEl[0].files[0]);
    fileForm.append('purpose', 'identity_document');
    var fileResult = await fetch('https://uploads.stripe.com/v1/files', {
      method: 'POST',
      headers: {'Authorization': 'Bearer ' + stripeApi._apiKey},
      body: fileForm,
    });
    var fileData = await fileResult.json();
    if (fileData.id) {
      verification = {
        verification: {
          document: fileData.id,
        }
      };
      $.extend(data.legal_entity, verification);
    }
  }

  var result = await stripeApi.createToken('account', omitNullDeep(data));
  if (result.token) {
    $('#stripe_account_form_token').val(result.token.id);
    callback();
  }
}

