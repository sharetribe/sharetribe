function add_validator_methods() {
  $.validator.
    addMethod( "valid_domain",
      function(value, element, param) {
        return value.match(new RegExp("(^[A-Za-z0-9_]*$)"));
      }
    );

  $.validator.
    addMethod( "valid_username",
      function(value, element, param) {
        return value.match(new RegExp("(^[A-Za-z0-9_]*$)"));
      }
    );

  $.validator.
    addMethod( "valid_email_ending_required",
      function(value, element, valid_email_ending_required) {
        if (valid_email_ending_required == "true") {
          var email_ending = value.split('@')[1];
          var personal_email_endings = ["hotmail.com","gmail.com","yahoo.com"];
          if ($.inArray(email_ending, personal_email_endings) != -1) {
            return false;
          }
        }
        return true;
      }
    );
}

function initialize_defaults() {
  $('select.language_select').selectmenu({style: 'dropdown', width: "100px"});
  add_validator_methods();
  $('.js_wrapper').addClass('js_enabled');
}

function initialize_dashboard(email_default_text) {
  $('#contact_request_email').watermark(email_default_text, {className: 'default_text'});
}

function initialize_login_form() {
  $('#password_forgotten_link').click(function() {
    $('#password_forgotten').slideToggle('fast');
    $('input.request_password').focus();
  });
  $('#login_form input.text_field:first').focus();
}

function initialize_campaign_page(select_default) {
  $('select.community_select').selectmenu({width: "370px", maxHeight: 175, style: 'dropdown'});
  //Remove unnecessary default "select neighborhood" option from the menu
  $('a:contains("' + select_default + '")').eq(1).parent().remove();
}

function initialize_new_tribe_form(locale, invalid_domain_message, domain_in_use_message, select_default) {
  auto_resize_text_areas("new_tribe_text_area");
  translate_validation_messages(locale);
  $('select.community_language_select').selectmenu({width: "540px", maxHeight: 175, style: 'dropdown'});
  //Remove unnecessary default option from the select tribe language menu
  if ($('a:contains("' + select_default + '")').eq(1).length < 1) {
    $('a:contains("' + select_default + '")').parent().remove();
  } else {
    $('a:contains("' + select_default + '")').eq(1).parent().remove();
  }
  $('#community_name').focus();
  $('#terms_link').click(function() { $('#terms').lightbox_me({centered: true}); });
  $('#invite_only_help_text_link').click(function() { $('#invite_only_help_text').lightbox_me({centered: true}); });
  var form_id = "#new_community";
  $(form_id).validate({
    errorPlacement: function(error, element) {
      if (element.attr("name") == "community[domain]") {
        error.appendTo(element.parent());
      } else if (element.attr("name") == "community[terms]") {
          error.appendTo(element.parent().parent().parent());
      } else {
        error.insertAfter(element);
      }
    },
    rules: {
      "community[name]": {required: true, minlength: 2, maxlength: 50},
      "community[domain]": {required: true, minlength: 2, maxlength: 50, valid_domain: true, remote: "/tribes/check_domain_availability"},
      "community[slogan]": {required: true, minlength: 2, maxlength: 100},
      "community[description]": {required: true, minlength: 2, maxlength: 500},
      "community[address]": {required: true, address_validator: true},
      "community[terms]": "required"
    },
    messages: {
      "community[domain]": { valid_domain: invalid_domain_message, remote: domain_in_use_message }
    },
    onkeyup: false,
    onclick: false,
    onfocusout: false,
    onsubmit: true,
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
    }
  });
}

function initialize_signup_form(locale, username_in_use_message, invalid_username_message, email_in_use_message, invalid_email_ending_message, valid_email_ending_required, community_category) {
  $('#terms_link').click(function() { $('#terms').lightbox_me({centered: true}); });
  $('input.text_field:first').focus();
  var form_id = "#new_person";
  translate_validation_messages(locale);
  $(form_id).validate({
    errorPlacement: function(error, element) {
      if (element.attr("name") == "person[terms]") {
        error.appendTo(element.parent().parent().parent().parent().parent());
      } else if (element.attr("name") == "recaptcha_response_field") {
        error.appendTo(element.parent().parent().parent().parent().parent().parent().parent().parent().parent());
      } else {
        error.insertAfter(element);
      }
    },
    rules: {
      "person[username]": {required: true, minlength: 3, maxlength: 20, valid_username: true, remote: "/people/check_username_availability"},
      "person[given_name]": {required: true, maxlength: 30},
      "person[family_name]": {required: true, maxlength: 30},
      "person[email]": {required: true, email: true, valid_email_ending_required: valid_email_ending_required, remote: ("/" + locale + "/people/check_email_availability_for_new_tribe?community_category=" + community_category)},
      "person[terms]": "required",
      "person[password]": { required: true, minlength: 4 },
      "person[password2]": { required: true, minlength: 4, equalTo: "#person_password" }
    },
    messages: {
      "person[username]": { valid_username: invalid_username_message, remote: username_in_use_message },
      "person[email]": { valid_email_ending_required: invalid_email_ending_message, remote: jQuery.format("{0}") }
    },
    onkeyup: false, //Only do validations when form focus changes to avoid exessive ASI calls
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
    }
  });
}

function initialize_enter_organization_email_form(locale, default_text,email_in_use_message, invalid_email_ending_message, valid_email_ending_required, community_category) {
  $('input.organization_email').watermark(default_text, {className: 'default_text'});
  var form_id = "#org_email_form";
  translate_validation_messages(locale);
  $(form_id).validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "email": {required: true, email: true, valid_email_ending_required: valid_email_ending_required, remote: ("/" + locale + "/people/check_email_availability_for_new_tribe?community_category=" + community_category)}
    },
    messages: {
      "email": { valid_email_ending_required: invalid_email_ending_message, remote: jQuery.format("{0}") }
    },
    onkeyup: false, //Only do validations when form focus changes to avoid exessive ASI calls
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
    }
  });
}

function open_url(url) {
  window.location = url;
  return false;
}
