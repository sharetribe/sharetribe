/* jshint sub: false */
/* Sripe API version 2019-02-19 */
window.ST = window.ST || {};
window.ST.stripe_form_i18n = window.ST.stripe_form_i18n || {
  'account_number' : 'Account number',
  'routing_number' : 'Routing number',
  'bank_code' : 'Bank code',
  'branch_code': 'Branch code',
  'transit_number' : 'Transit number',
  'institution_number': 'Institution number',
  'format_varies_by_bank' : 'Format varies by bank',
  'bsb': 'BSB',
  'error_message': 'Invalid format',
  'clearing_code': 'Clearing code',
  'sort_code': 'Sort code',
  'must_match': "must match",
  'a_dash': 'a dash',
  'digits': 'digits',
  'digits_or_chars': 'digits or A-Z chars'
};
(function(module) {
  var BANK_RULES, stripeApi, stripeFormData;

  function i18n_label(key, default_value) {
    var translated = window.ST.stripe_form_i18n[key];
    if(translated) return translated;
    return key ? key : default_value;
  }

  function show_if(element, value) {
    if(value.format) {
      element.show();
    } else {
      element.hide();
      element.find("input").val("");
    }
  }

  function update_bank_number_form(country) {
    var rule = BANK_RULES[country] || {};

    var rule_account_number = rule.account_number || {};
    var rule_routing_number = rule.routing_number || {};
    var rule_routing_1      = rule.routing_1 || {};
    var rule_routing_2      = rule.routing_2 || {};

    $(".bank-account-number label:first").text(i18n_label(rule_account_number.title, i18n_label('account_number', 'Account number'))+"*");
    $(".bank-routing-number label:first").text(i18n_label(rule_routing_number.title, i18n_label('routing_number', 'Routing number'))+"*");
    $(".bank-routing-1 label:first").text(i18n_label(rule_routing_1.title, i18n_label('routing_1', 'Bank code'))+"*");
    $(".bank-routing-2 label:first").text(i18n_label(rule_routing_2.title, i18n_label('routing_2', 'Branch code'))+"*");

    $(".bank-account-number input").attr('placeholder', i18n_label(rule_account_number.format, rule_account_number.format));
    $(".bank-routing-number input").attr('placeholder', rule_routing_number.format);
    $(".bank-routing-1 input").attr('placeholder', rule_routing_1.format);
    $(".bank-routing-2 input").attr('placeholder', rule_routing_2.format);

    show_if($(".bank-routing-number"), rule_routing_number);
    show_if($(".bank-routing-1"), rule_routing_1);
    show_if($(".bank-routing-2"), rule_routing_2);
    $("[phone_number]").attr('placeholder', rule.phone_number);
  }

  var getValue = function(name, valueType) {
    var value,
      item = stripeFormData.find(function(x) {
      return x.name === 'stripe_account_form[' + name + ']';
    });
    if (item) {
      if (valueType === 'int') {
        value = parseInt(item.value);
      } else {
        value = item.value;
      }
    }
    return item ? value : null;
  };

  var omitNullDeep = function(obj) {
    return _.reduce(obj, function(result, value, key) {
      if (_.isObject(value)) {
        result[key] = omitNullDeep(value);
      }
      else if (!_.isNull(value)) {
        result[key] = value;
      }
      return result;
    }, {});
  };

  var removeSpaces = function() {
    $('.bank-account-number, .bank-routing-number, .bank-routing-1, .bank-routing-2')
      .find('input:enabled').each(function() {
        var input = $(this),
          value = input.val().replace(/\s+/g, '').toUpperCase();
        input.val(value);
      });
  };

  var prepareData = function(options) {
    var country = getValue('address_country'),
      firstName = getValue('first_name'),
      lastName = getValue('last_name'),
      address, person;

    var data = {
      business_type: 'individual',
      individual: {
      },

      tos_shown_and_accepted: true
    };

    if (country == 'JP') {
      address = {
        address_kana: {
          postal_code: getValue('address_kana_postal_code'),
          state: getValue('address_kana_state'),
          city: getValue('address_kana_city'),
          town: getValue('address_kana_town'),
          line1: getValue('address_kana_line1'),
        },
        address_kanji: {
          postal_code: getValue('address_kanji_postal_code'),
          state: getValue('address_kanji_state'),
          city: getValue('address_kanji_city'),
          town: getValue('address_kanji_town'),
          line1: getValue('address_kanji_line1'),
        },
      };
      person = {
        first_name_kana: getValue('first_name_kana'),
        last_name_kana: getValue('last_name_kana'),
        first_name_kanji: getValue('first_name_kanji'),
        last_name_kanji: getValue('last_name_kanji'),
        phone: getValue('phone')
      };
      if (!options.update) {
        $.extend(person, {
          dob: {
            day: getValue('birth_date(3i)', 'int'),
            month: getValue('birth_date(2i)', 'int'),
            year: getValue('birth_date(1i)', 'int'),
          },
          gender: getValue('gender')
        });
      }
    } else {
      address = {
        address: {
          city: getValue('address_city'),
          state: getValue('address_state'),
          country: getValue('address_country'),
          postal_code: getValue('address_postal_code'),
          line1: getValue('address_line1'),
        }
      };
      if (['PR'].includes(country)) {
        address.address.country = 'US';
        address.address.state = country;
      }

      person = {
        first_name: firstName,
        last_name: lastName,
        phone: getValue('phone'),
        email: getValue('email'),
        id_number: ['US', 'CA', 'HK', 'SG', 'PR', 'MX'].includes(country) ? getValue('id_number') : null,
        ssn_last_4: ['US', 'PR'].includes(country) ? getValue('ssn_last_4') : null,
      };
      if (!options.update) {
        $.extend(person, {
          dob: {
            day: getValue('birth_date(3i)', 'int'),
            month: getValue('birth_date(2i)', 'int'),
            year: getValue('birth_date(1i)', 'int'),
          }
        });
      }
    }

    $.extend(data.individual, address, person);
    return data;
  };

  var init = function(options) {
    BANK_RULES = options.bank_rules;
    window.ST.stripe_test_api_mode = options.stripe_test_mode;
    stripeApi = Stripe(options.api_publishable_key);
    add_validators();
    $("#stripe_account_form_address_country").change(function(){
      var showElement = function (el, show) {
        if (show) {
          $(el).find('input, select').prop('disabled', false);
          $(el).show();
        } else {
          $(el).find('input, select').prop('disabled', true);
          $(el).hide();
        }
      };
      var country = $(this).val();
      if(country) {
        if($("#stripe-terms-link").size() > 0 ) {
          $("#stripe-terms-link").attr('href', $("#stripe-terms-link").data("terms-url").replace(/COUNTRY/, country.toLowerCase()));
        }
        $(".address-lines").show();
        $(".country-dependent").each(function(){
          var only = $(this).data("country-only");
          var except = $(this).data("country-except");
          if(only) {
            showElement(this, only.indexOf(country) >= 0);
          }
          if(except) {
            showElement(this, except.indexOf(country) < 0);
          }
        });
        $("label.error").hide();
      } else {
        $(".address-lines").hide();
        $(".country-dependent").hide();
      }
      update_bank_number_form(country);
      if (options.update) {
        $('input[stripe-bank-account-ready]').prop('disabled', true);
      }
    });
    $("#stripe_account_form_address_country").trigger('change');
    $('#stripe-europe-name').addClass('country-dependent');
    $("#stripe-account-form").validate({
      submitHandler: function(form) {
        removeSpaces();
        stripeFormData = $(form).serializeArray();
        var data = prepareData(options),
          documentFrontEl = $('#stripe_account_form_document_front'),
          documentFront = documentFrontEl.length > 0,
          documentBackEl = $('#stripe_account_form_document_back'),
          documentBack = documentBackEl.length > 0,
          additionalDocumentFrontEl = $('#stripe_account_form_additional_document_front'),
          additionalDocumentFront = additionalDocumentFrontEl.length > 0,
          additionalDocumentBackEl = $('#stripe_account_form_additional_document_back'),
          additionalDocumentBack = additionalDocumentBackEl.length > 0,
          fileElements = {};

        var stripeData = {
          data: data,
          success: function(token) {
            $('#stripe_account_form_token').val(token.id);
            form.submit();
          },
          error: function(error) {
            console.log('Stripe token error ="' + error.message + '" "' + error.param + '" "' + error.type + '"');
            showError(options.error_nofication.replace('%{message}', error.message));
          }
        };
        if (documentFront) {
          fileElements.documentFront = documentFrontEl[0].files[0];
        }
        if (documentBack) {
          fileElements.documentBack = documentBackEl[0].files[0];
        }
        if (additionalDocumentFront) {
          fileElements.additionalDocumentFront = additionalDocumentFrontEl[0].files[0];
        }
        if (additionalDocumentBack) {
          fileElements.additionalDocumentBack = additionalDocumentBackEl[0].files[0];
        }
        if (documentFront || additionalDocumentFront) {
          stripeUploadFiles({
            fileElements: fileElements,
            fileCallback: function(fileData) {
              var verification = {
                verification: {
                  document: {
                  },
                  additional_document: {
                  }
                }
              };
              if (fileData.documentFront) {
                verification.verification.document.front = fileData.documentFront.id;
              }
              if (fileData.documentBack) {
                verification.verification.document.back = fileData.documentBack.id;
              }
              if (fileData.additionalDocumentFront) {
                verification.verification.additional_document.front = fileData.additionalDocumentFront.id;
              }
              if (fileData.additionalDocumentBack) {
                verification.verification.additional_document.back = fileData.additionalDocumentBack.id;
              }
              $.extend(data.individual, verification);
              stripeToken(stripeData);
            }
          });
        } else {
          stripeToken(stripeData);
        }
      }
    });
    $('#update_also_bank_account').on('change', function() {
      var inputs = $('input[stripe-bank-account-ready]');
      if ($(this).is(':checked')) {
        inputs.filter(':visible').prop('disabled', false);
      } else {
        inputs.prop('disabled', true);
      }
    });
  };

  var add_validators = function() {
    function explain_regexp(value) {
      var t = value;
      t = t.replace(/-\[/g, ';'+i18n_label('a_dash', 'a dash')+';[');
      t = t.replace(/\[0-9\]\{(\d+)}/g, ';$1 '+i18n_label('digits', 'digits')+';');
      t = t.replace(/\[A-Z0-9\]\{(\d+)}/g, ';$1 '+i18n_label('digits_or_chars', 'digits or chars')+';');
      t = t.replace(/\[0-9\]\{(\d+),(\d+)}/g, ';$1-$2 '+i18n_label('digits', 'digits')+';');
      t = t.replace(/\[A-Z0-9\]\{(\d+),(\d+)}/g, ';$1-$2 '+i18n_label('digits_or_chars', 'digits or chars')+';');
      t = t.replace(/\[A-Z\]\{(\d+)}/g, ';$1 letter country code;');
      t = t.replace(/;+/g, ', ').replace(/^,\s*/,'').replace(/,\s*$/, '');
      return t;
    }
    $.validator.addMethod(
      "country_regexp",
      function(value, element, field) {
        var country = $("#stripe_account_form_address_country").val();
        var rule = BANK_RULES[country] || {};
        var re = (rule[field] || {} ).regexp;
        if(window.ST.stripe_test_api_mode) {
          re = (rule[field] || {}).test_regexp;
        }
        if(re) {
          var rx = new RegExp("^"+re+"$");
          var testValue = value.replace(/\s+/g, '').toUpperCase();
          return rx.test(testValue);
        }
        return this.optional(element) || $(element).val();
      },
      function(field, element) {
        var country = $("#stripe_account_form_address_country").val();
        var rule = BANK_RULES[country] || {};
        var title = (rule[field] || {} ).title;
        var regexp = (rule[field] || {} ).regexp;
        if(window.ST.stripe_test_api_mode) {
          regexp = (rule[field] || {}).test_regexp;
        }
        var def_title = field == 'account_number' ? i18n_label(field, 'Account number') : field;
        return i18n_label(title, def_title) + " " + i18n_label("must_match", "must be in the following format:")+ " " + explain_regexp(regexp);
      }
    );
    // Canada
    $.validator.addMethod(
      "ca-social-insurance-number",
      function(value, element, field) {
        var sin = new SocialInsuranceNumber(value);
        return sin.isValid();
      }
    );
  };

  var showError = function(message) {
    ST.utils.showError(message, 'error');
    $('html, body').animate({ scrollTop: $('.flash-notifications').offset().top}, 1000);
  };

  module.StripeBankForm3 = {
    init: init
  };

//////////////////////////////////////////////////////////////////////
// compiled by http://babeljs.io/repl/ from stripe_token_original3.js
//////////////////////////////////////////////////////////////////////
/* jshint ignore:start */
// contains async-await
var stripeUploadFiles = function stripeUploadFiles(options) {
  var uploadFiles = function uploadFiles() {
    var fileData, itemKey, fileForm, additionalFileForm, additionalFileData, fileResult;
    return regeneratorRuntime.async(function uploadFiles$(_context) {
      while (1) {
        switch (_context.prev = _context.next) {
          case 0:
            fileData = {};
            _context.t0 = regeneratorRuntime.keys(options.fileElements);

          case 2:
            if ((_context.t1 = _context.t0()).done) {
              _context.next = 17;
              break;
            }

            itemKey = _context.t1.value;
            fileElement = options.fileElements[itemKey];
            fileForm = new FormData();
            additionalFileForm = new FormData(), additionalFileData = null;
            fileForm.append('file', fileElement);
            fileForm.append('purpose', 'identity_document');
            _context.next = 11;
            return regeneratorRuntime.awrap(fetch('https://uploads.stripe.com/v1/files', {
              method: 'POST',
              headers: {
                'Authorization': 'Bearer ' + stripeApi._apiKey
              },
              body: fileForm
            }));

          case 11:
            fileResult = _context.sent;
            _context.next = 14;
            return regeneratorRuntime.awrap(fileResult.json());

          case 14:
            fileData[itemKey] = _context.sent;
            _context.next = 2;
            break;

          case 17:
            return _context.abrupt("return", fileData);

          case 18:
          case "end":
            return _context.stop();
        }
      }
    });
  };

  uploadFiles().then(function (data) {
    options.fileCallback(data);
  });
};

var stripeToken = function stripeToken(options) {
  var result;
  return regeneratorRuntime.async(function stripeToken$(_context2) {
    while (1) {
      switch (_context2.prev = _context2.next) {
        case 0:
          _context2.next = 2;
          return regeneratorRuntime.awrap(stripeApi.createToken('account', omitNullDeep(options.data)));

        case 2:
          result = _context2.sent;

          if (result.token) {
            options.success(result.token);
          }

          if (result.error) {
            options.error(result.error);
          }

        case 5:
        case "end":
          return _context2.stop();
      }
    }
  });
};
/* jshint ignore:end */
})(window.ST);
