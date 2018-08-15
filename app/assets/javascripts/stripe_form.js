window.ST = window.ST || {};
window.ST.stripe_form_i18n = {
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
  var TEST_IBAN = '89370400440532013000';

  var BANK_RULES = {
    AU: {
      account_number: { format: 'format_varies_by_bank', regexp: '[0-9]{6,10}', test_regexp: '[0-9]{6,10}'},
      routing_number: { title: 'bsb',  format: '123456', regexp: '[0-9]{6}', test_regexp: '[0-9]{6}'}
    },
    AT: {
      account_number: { title: 'IBAN', format: 'AT611904300235473201', regexp: 'AT[0-9]{2}[0-9]{16}', test_regexp: 'AT'+TEST_IBAN }
    },
    BE: {
      account_number: { title: 'IBAN', format: 'BE12345678912345', regexp: 'BE[0-9]{2}[0-9]{12}', test_regexp: 'BE'+TEST_IBAN }
    },
    BR: {
      account_number: { format: 'format_varies_by_bank' },
      routing_1: { title: "bank_code", format: '123', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      routing_2: { title: 'branch_code', regexp: '[0-9]{4,5}', test_regexp: '[0-9]{4,5}' },
      separator: "-"
    },
    CA: {
      account_number: { format: 'format_varies_by_bank' },
      routing_1: { title: 'transit_number', format: '12345', regexp: '[0-9]{5}', test_regexp: '[0-9]{5}'  },
      routing_2: { title: 'institution_number', format: '123', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      separator: "-"
    },
    DK: {
      account_number: {title: 'IBAN', format: 'DK5000400440116243', regexp: 'DK[0-9]{2}[0-9]{14}', test_regexp: 'DK'+TEST_IBAN }
    },
    FI: {
      account_number: {title: 'IBAN', format: 'FI2112345600000785', regexp: 'FI[0-9]{2}[0-9]{14}', test_regexp: 'FI'+TEST_IBAN }
    },
    FR: {
      account_number: {title: 'IBAN', format: 'FR1420041010050500013M02606', regexp: 'FR[0-9]{2}[0-9]{10}[A-Z0-9]{11}[0-9]{2}', test_regexp: 'FR'+TEST_IBAN }
    },
    DE: {
      account_number: {title: 'IBAN', format: 'DE89370400440532013000', regexp: 'DE[0-9]{2}[0-9]{18}', test_regexp: 'DE'+TEST_IBAN }
    },
    GI: {
      account_number: { title: 'IBAN', format: 'GI75NWBK000000007099453', regexp: 'GI[0-9]{2}[A-Z]{4}[A-Z0-9]{15}', test_regexp: 'GI'+TEST_IBAN }
    },
    HK: {
      account_number: { format: '123456-789', regexp: '[0-9]{5,6}-[0-9]{1,3}', test_regexp: '[0-9]{5,6}-[0-9]{1,3}' },
      routing_1: { title: 'clearing_code', format: '123', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      routing_2: { title: 'branch_code', format: '456', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      separator: "-"
    },
    IE: {
      account_number: {title: 'IBAN', format: 'IE29AIBK93115212345678', regexp: 'IE[0-9]{2}[A-Z0-9]{4}[0-9]{14}', test_regexp: 'IE'+TEST_IBAN },
    },
    IT: {
      account_number: {title: 'IBAN', format: 'IT60X0542811101000000123456', regexp: 'IT[0-9]{2}[A-Z]{1}[0-9]{5}[0-9]{5}[A-Z0-9]{12}', test_regexp: 'IT'+TEST_IBAN },
    },
    JP: {
      account_number: {format: '1234567', regexp: '[0-9]{6,8}', test_regexp: '[0-9]{6,8}' },
      routing_1: {title: "bank_code", format: '0123', regexp: '[0-9]{4}', test_regexp: '[0-9]{4}'},
      routing_2: {title: "branch_code", format: '456', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}'},
      separator: ""
    },
    LU: {
      account_number: {title: 'IBAN', format: 'LU280019400644750000', regexp: 'LU[0-9]{2}[0-9]{3}[A-Z0-9]{13}', test_regexp: 'LU'+TEST_IBAN },
    },
    MX: {
      account_number: {title: 'CLABE', format: '123456789012345678', regexp: '[0-9]{18}', test_regexp: '[0-9]{18}' }
    },
    NL: {
      account_number: {title: 'IBAN', format: 'NL39RABO0300065264', regexp: 'NL[0-9]{2}[A-Z]{4}[0-9]{10}', test_regexp: 'NL'+TEST_IBAN }
    },
    NZ: {
      account_number: {format: '11-0000-0000000-010', regexp: '[0-9]{2}\-[0-9]{4}\-[0-9]{7}\-[0-9]{2,3}', test_regexp: '[0-9]{2}\-[0-9]{4}\-[0-9]{7}\-[0-9]{2,3}' },
    },
    NO: {
      account_number: {title: 'IBAN', format: 'NO9386011117947', regexp: 'NO[0-9]{2}[0-9]{11}', test_regexp: 'NO'+TEST_IBAN },
    },
    PT: {
      account_number: {title: 'IBAN', format: 'PT50123443211234567890172', regexp: 'PT[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{11}[0-9]{2}', test_regexp: 'PT'+TEST_IBAN },
    },
    SG: {
      account_number: {format: '123456789012', regexp: '[0-9]{6-12}', test_regexp: '[0-9]{6-12}' },
      routing_1: {title: "bank_code", format: '1234', regexp: '[0-9]{4}', test_regexp: '[0-9]{4}' },
      routing_2: {title: 'branch_code', format: '567', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}'},
      separator: "-"
    },
    ES: {
      account_number: {title: 'IBAN', format: 'ES9121000418450200051332', regexp: 'ES[0-9]{2}[0-9]{20}', test_regexp: 'ES'+TEST_IBAN }
    },
    SE: {
      account_number: {title: 'IBAN', format: 'SE3550000000054910000003', regexp: 'SE[0-9]{2}[0-9]{20}', test_regexp: 'SE'+TEST_IBAN }
    },
    CH: {
      account_number: {title: 'IBAN', format: 'CH9300762011623852957', regexp: 'CH[0-9]{2}[0-9]{5}[A-Z0-9]{12}', test_regexp: 'CH'+TEST_IBAN }
    },
    GB: {
      account_number: {format: '01234567', regexp: '[0-9]{8}', test_regexp: '[0-9]{8}' },
      routing_number: {title: 'sort_code', format: '12-34-56', regexp: '[0-9]{2}-[0-9]{2}-[0-9]{2}', test_regexp: '108800' }
    },
    US: {
      account_number: {format: 'format_varies_by_bank' },
      routing_number: {title: 'routing_number', format: '111000000', regexp: '[0-9]{9}', test_regexp: '[0-9]{9}' }
    },
    PR: {
      account_number: {format: 'format_varies_by_bank' },
      routing_number: {title: 'routing_number', format: '111000000', regexp: '[0-9]{9}', test_regexp: '[0-9]{9}' }
    }
  };
  var stripeApi, stripeFormData;

  function i18n_label(key, default_value) {
    var translated = window.ST.stripe_form_i18n[key];
    if(translated) return translated;
    return key ? key : default_value;
  }

  function show_if(element, value) {
    if(value['format']) {
      element.show();
    } else {
      element.hide();
      element.find("input").val("");
    }
  }

  function update_bank_number_form(country) {
    var rule = BANK_RULES[country] || {};

    var rule_account_number = rule['account_number'] || {};
    var rule_routing_number = rule['routing_number'] || {};
    var rule_routing_1      = rule['routing_1'] || {};
    var rule_routing_2      = rule['routing_2'] || {};

    $(".bank-account-number label:first").text(i18n_label(rule_account_number['title'], i18n_label('account_number', 'Account number'))+"*");
    $(".bank-routing-number label:first").text(i18n_label(rule_routing_number['title'], i18n_label('routing_number', 'Routing number'))+"*");
    $(".bank-routing-1 label:first").text(i18n_label(rule_routing_1['title'], i18n_label('routing_1', 'Bank code'))+"*");
    $(".bank-routing-2 label:first").text(i18n_label(rule_routing_2['title'], i18n_label('routing_2', 'Branch code'))+"*");

    $(".bank-account-number input").attr('placeholder', i18n_label(rule_account_number['format'], rule_account_number['format']));
    $(".bank-routing-number input").attr('placeholder', rule_routing_number['format']);
    $(".bank-routing-1 input").attr('placeholder', rule_routing_1['format']);
    $(".bank-routing-2 input").attr('placeholder', rule_routing_2['format']);

    show_if($(".bank-routing-number"), rule_routing_number);
    show_if($(".bank-routing-1"), rule_routing_1);
    show_if($(".bank-routing-2"), rule_routing_2);
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

  module.initStripeBankForm = function(options) {
    window.ST.stripe_test_api_mode = options.stripe_test_mode;
    stripeApi = Stripe(options.api_publishable_key);
    $("#stripe_account_form_address_country").change(function(){
      var showElement = function (el, show) {
        if (show) {
          $(el).find('input').prop('disabled', false);
          $(el).show();
        } else {
          $(el).find('input').prop('disabled', true);
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
            showElement(this, only.indexOf(country) >= 0)
          }
          if(except) {
            showElement(this, except.indexOf(country) < 0)
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
    $("#stripe-account-form").validate({
      submitHandler: function(form) {
        removeSpaces();
        stripeFormData = $(form).serializeArray();
        stripeToken(options, function() {
          form.submit();
        });
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

  function explain_regexp(value) {
    var t = value;
    t = t.replace(/-\[/g, ';'+i18n_label('a_dash', 'a dash')+';[');
    t = t.replace(/\[0-9\]\{(\d+)}/g, ';$1 '+i18n_label('digits', 'digits')+';');
    t = t.replace(/\[A-Z0-9\]\{(\d+)}/g, ';$1 '+i18n_label('digits_or_chars', 'digits or chars')+';');
    t = t.replace(/\[0-9\]\{(\d+),(\d+)}/g, ';$1-$2 '+i18n_label('digits', 'digits')+';');
    t = t.replace(/\[A-Z0-9\]\{(\d+),(\d+)}/g, ';$1-$2 '+i18n_label('digits_or_chars', 'digits or chars')+';');
    t = t.replace(/\[A-Z\]\{(\d+)}/g, ';$1 letter country code;');
    t = t.replace(/;+/g, ', ').replace(/^,\s*/,'').replace(/,\s*$/, '')
    return t;
  }
  $.validator.addMethod(
    "country_regexp",
    function(value, element, field) {
      var country = $("#stripe_account_form_address_country").val();
      var rule = BANK_RULES[country] || {};
      var re = (rule[field] || {} )['regexp'];
      if(window.ST.stripe_test_api_mode) {
        re = (rule[field] || {})['test_regexp'];
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
      var title = (rule[field] || {} )['title'];
      var regexp = (rule[field] || {} )['regexp'];
      if(window.ST.stripe_test_api_mode) {
        regexp = (rule[field] || {})['test_regexp'];
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

//////////////////////////////////////////////////////////////////////
// compiled by http://babeljs.io/repl/ from stripe_token_original.js
//////////////////////////////////////////////////////////////////////
function _asyncToGenerator(fn) {
  return function() {
    var gen = fn.apply(this, arguments);
    return new Promise(function(resolve, reject) {
      function step(key, arg) {
        try {
          var info = gen[key](arg);
          var value = info.value;
        } catch (error) {
          reject(error);
          return;
        }
        if (info.done) {
          resolve(value);
        } else {
          return Promise.resolve(value).then(
            function(value) {
              step("next", value);
            },
            function(err) {
              step("throw", err);
            }
          );
        }
      }
      return step("next");
    });
  };
}

// contains async-await
var stripeToken = (function() {
  var _ref = _asyncToGenerator(
    /*#__PURE__*/ regeneratorRuntime.mark(function _callee(options, callback) {
      var country,
        firstName,
        lastName,
        data,
        address,
        person,
        verificationEl,
        verify,
        verification,
        fileForm,
        fileResult,
        fileData,
        result;
      return regeneratorRuntime.wrap(
        function _callee$(_context) {
          while (1) {
            switch ((_context.prev = _context.next)) {
              case 0:
                (country = getValue("address_country")),
                  (firstName = getValue("first_name")),
                  (lastName = getValue("last_name"));
                data = {
                  legal_entity: {
                    type: "individual"
                  },

                  tos_shown_and_accepted: true
                };
                address = {
                  address: {
                    city: getValue("address_city"),
                    state: getValue("address_state"),
                    country: getValue("address_country"),
                    postal_code: getValue("address_postal_code"),
                    line1: getValue("address_line1")
                  }
                };
                person = {
                  first_name: firstName,
                  last_name: lastName,
                  dob: {
                    day: getValue("birth_date(3i)", "int"),
                    month: getValue("birth_date(2i)", "int"),
                    year: getValue("birth_date(1i)", "int")
                  },
                  personal_id_number: ["US", "CA", "HK", "SG", "PR"].includes(country)
                    ? getValue("personal_id_number")
                    : null,
                  ssn_last_4: country == "US" ? getValue("ssn_last_4") : null
                };

                $.extend(data.legal_entity, address, person);

                (verificationEl = $("#stripe_account_form_document")),
                  (verify = verificationEl.length > 0),
                  (verification = null);

                if (!verify) {
                  _context.next = 17;
                  break;
                }

                fileForm = new FormData();

                fileForm.append("file", verificationEl[0].files[0]);
                fileForm.append("purpose", "identity_document");
                _context.next = 12;
                return fetch("https://uploads.stripe.com/v1/files", {
                  method: "POST",
                  headers: { Authorization: "Bearer " + stripeApi._apiKey },
                  body: fileForm
                });

              case 12:
                fileResult = _context.sent;
                _context.next = 15;
                return fileResult.json();

              case 15:
                fileData = _context.sent;

                if (fileData.id) {
                  verification = {
                    verification: {
                      document: fileData.id
                    }
                  };
                  $.extend(data.legal_entity, verification);
                }

              case 17:
                _context.next = 19;
                return stripeApi.createToken("account", omitNullDeep(data));

              case 19:
                result = _context.sent;

                if (result.token) {
                  $("#stripe_account_form_token").val(result.token.id);
                  callback();
                }

              case 21:
              case "end":
                return _context.stop();
            }
          }
        },
        _callee,
        this
      );
    })
  );

  return function stripeToken(_x, _x2) {
    return _ref.apply(this, arguments);
  };
})();
})(window.ST);
