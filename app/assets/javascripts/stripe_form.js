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
      account_number: {format: '110000-0000000-010', regexp: '[0-9]{6}\-[0-9]{7}\-[0-9]{2,3}', test_regexp: '[0-9]{6}\-[0-9]{7}\-[0-9]{2,3}' }, 
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
    }   
  };

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

  module.initStripeBankForm = function(stripe_test_api_mode) {
    window.ST.stripe_test_api_mode = stripe_test_api_mode;
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
    });
    $("#stripe_account_form_address_country").trigger('change');
    $("#stripe-account-form").validate({
      submitHandler: function(form) {
        var removeSpacesInputs = [".bank-account-number input", ".bank-routing-number input",
          ".bank-routing-1 input", ".bank-routing-2 input"];
        for (var index in removeSpacesInputs) {
          var input = $(removeSpacesInputs[index]);
          var value = input.val().replace(/\s+/g, '');
          input.val(value);
        }
        form.submit();
      }
    });
    $(".bank-account-number input").rules("add", { country_regexp: 'account_number' } );
    $(".bank-routing-number input").rules("add", { country_regexp: 'routing_number' } );
    $(".bank-routing-1 input").rules("add", { country_regexp: 'routing_1' } );
    $(".bank-routing-2 input").rules("add", { country_regexp: 'routing_2' } );
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
        var testValue = value.replace(/\s+/g, '');
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
})(window.ST);

