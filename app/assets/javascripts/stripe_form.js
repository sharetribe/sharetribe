window.ST = window.ST || {};

(function(module) {
  var BANK_RULES = {
    AT: { routing_number: {title: "IBAN", format: "AT611904300235473201"} },
    BE: { routing_number: {title: "IBAN", format: "BE12345678912345"} },
    CA: { routing_number: {title: "Transit Number (12345) + Institution Number (678)", format: "12345678"}, account_number: {title: "Account Number" }},
    DK: { routing_number: {title: "IBAN", format: "DK12345678912345"} },
    FI: { routing_number: {title: "IBAN", format: "FI2112345600000785"} },
    FR: { routing_number: {title: "IBAN", format: "FR1420041010050500013M02606 (27 characters)"}},
    DE: { routing_number: {title: "IBAN", format: "DE89370400440532013000 (22 characters)"}},
    IE: { routing_number: {title: "IBAN", format: "IE29AIBK93115212345678 (22 characters)"}},
    IT: { routing_number: {title: "IBAN", format: "IT60X0542811101000000123456 (27 characters)"}},
    LU: { routing_number: {title: "IBAN", format: "LU280019400644750000 (20 characters)"}},
    MX: { routing_number: {title: "CLABE",format: "123456789012345678 (18 characters)"}},
    NL: { routing_number: {title: "IBAN", format: "NL39RABO0300065264 (18 characters)"}},
    NO: { routing_number: {title: "IBAN", format: "NO9386011117947 (15 characters)"}},
    PT: { routing_number: {title: "IBAN", format: "PT50123443211234567890172 (25 characters)"}},
    ES: { routing_number: {title: "IBAN", format: "ES9121000418450200051332 (24 characters)"}},
    SE: { routing_number: {title: "IBAN", format: "SE3550000000054910000003 (24 characters)"}},
    CH: { routing_number: {title: "IBAN", format: "CH9300762011623852957 (21 characters)"}},
    GB: { routing_number: {title: "Sort Code", format: "12-34-56"}, account_number: {title:  "Account Number", format: "01234567 or IBAN GB82WEST12345698765432 (22 characters)"}},
    US: { routing_number: {title: "Routing number", format: "111000000 (9 characters)"}, account_number: {title: "Account Number", format: "format varies"}}
  };
  var DEFAULT_CURRENCIES  = {
     AT: "EUR",
     BE: "EUR",
     CA: "CAD",
     CH: "CHF",
     DE: "EUR",
     DK: "DKK",
     ES: "EUR",
     FI: "EUR",
     FR: "EUR",
     GB: "GBP",
     IE: "EUR",
     IT: "EUR",
     LU: "EUR",
     NL: "EUR",
     NO: "NOK",
     PT: "EUR",
     SE: "SEK",
     US: "USD"
  };
  function get_placeholder(country, field) {
    var record = BANK_RULES[country];
    if(!record || !record[field]) return "";
    record = record[field];
    var placeholder = [];
    if(record.title) placeholder.push(record.title);
    if(record.format) placeholder.push(record.format);
    return placeholder.join(", ")
  }
  module.initStripeBankForm = function() {
    var prefix = "#stripe_bank_account_form";
    $(prefix+"_bank_country").change(function(){
      var country = $(this).val();
      $(prefix+"_bank_account_number").prop('placeholder', get_placeholder(country, 'account_number'));
      $(prefix+"_bank_routing_number").prop('placeholder', get_placeholder(country, 'routing_number'));
      $(prefix+"_bank_currency").val(DEFAULT_CURRENCIES[country]);
    });
    $(prefix+"_bank_country").trigger('change');
  }
})(window.ST);

