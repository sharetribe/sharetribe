function initialize_confirmation_pending_form(locale, email_in_use_message) {
  $('#mistyped_email_link').click(function() {
    $('#password_forgotten').slideToggle('fast');
    $("html, body").animate({ scrollTop: $(document).height() }, 1000);
    $('input.email').focus();
  });
  var change_form_id = "#change_mistyped_email_form";
  $(change_form_id).validate({
     errorPlacement: function(error, element) {
       error.insertAfter(element);
     },
     rules: {
       "person[email]": {required: true, email: true, remote: "/people/check_email_availability_and_validity"}
     },
     messages: {
       "person[email]": { remote: email_in_use_message }
     },
     onkeyup: false, //Only do validations when form focus changes to avoid exessive calls
     submitHandler: function(form) {
       disable_and_submit(change_form_id, form, "false", locale);
     }
  });
  var resend_form_id = "#resend_email_confirmation";
  $(resend_form_id).submit(function(e) {
    disable_submit_button(resend_form_id, locale);
  });
}

/* This should be used with non-ajax forms only */
function disable_and_submit(form_id, form, ajax, locale) {
  disable_submit_button(form_id, locale);
  form.submit();
}

/* This should be used always with ajax forms */
function prepare_ajax_form(form_id, locale, rules) {
  $(form_id).ajaxForm({
    dataType: 'script',
    beforeSubmit: function() {
      $(form_id).validate({
        rules: rules
      });
      if ($(form_id).valid() == true) {
        disable_submit_button(form_id, locale);
      }
      return $(form_id).valid();
    }
  });
}

function disable_submit_button(form_id) {
  $(form_id).find("button").attr('disabled', 'disabled');

  var json = ST.jsonTranslations;
  $(form_id).find("button").text(json.please_wait);
}

function auto_resize_text_areas(class_name) {
  autosize(document.querySelectorAll('textarea.' + class_name));
}

function translate_validation_messages(locale) {
  function formatMinMaxMessage(message) {
    return function(otherName) {
      var otherVal = ST.utils.findElementByName(otherName).val();
      return jQuery.validator.format(message, otherVal);
    }
  }

  var json = ST.jsonTranslations;
  jQuery.extend(jQuery.validator.messages, {
      required: json.validation_messages.required,
      remote: json.validation_messages.remote,
      email: json.validation_messages.email,
      url: json.validation_messages.url,
      date: json.validation_messages.date,
      dateISO: json.validation_messages.dateISO,
      number: json.validation_messages.number,
      digits: json.validation_messages.digits,
      creditcard: json.validation_messages.creditcard,
      equalTo: json.validation_messages.equalTo,
      accept: json.validation_messages.accept,
      maxlength: jQuery.validator.format(json.validation_messages.maxlength),
      minlength: jQuery.validator.format(json.validation_messages.minlength),
      rangelength: jQuery.validator.format(json.validation_messages.rangelength),
      range: jQuery.validator.format(json.validation_messages.range),
      max: jQuery.validator.format(json.validation_messages.max),
      min: jQuery.validator.format(json.validation_messages.min),
      address_validator: jQuery.validator.format(json.validation_messages.address_validator),
      money: jQuery.validator.format(json.validation_messages.money),
      night_selected: jQuery.validator.format(json.validation_messages.night_selected),
      availability_range: jQuery.validator.format(json.validation_messages.availability_range),
      min_bound: formatMinMaxMessage(json.validation_messages.min_bound),
      max_bound: formatMinMaxMessage(json.validation_messages.max_bound),
      number_min: jQuery.validator.format(json.validation_messages.min),
      number_max: jQuery.validator.format(json.validation_messages.max),
      number_no_decimals: json.validation_messages.number_no_decimals,
      number_decimals: json.validation_messages.number_decimals,
      number_conditional_decimals: json.validation_messages.number
  });
}
