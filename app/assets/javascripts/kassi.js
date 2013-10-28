// Custom Javascript functions for Sharetribe
// Add custom validation methods
function add_validator_methods() {
  
  // If some element is required, it should be validated even if it's hidden
  $.validator.setDefaults({ ignore: [] });
  
  $.validator.
    addMethod("accept",
      function(value, element, param) {
        return value.match(new RegExp(/(\.jpe?g|\.gif|\.png|^$)/i));
      }
    );

  $.validator.
    addMethod( "valid_username", 
      function(value, element, param) {
        return value.match(new RegExp("(^[A-Za-z0-9_]*$)"));
      }
    );
  
  $.validator.
    addMethod("regex",
      function(value, element, regexp) {
        var re = new RegExp(regexp);
        return re.test(value);
      }
  );
  $.validator.
    addMethod("email_list",
      function(value, element, param) {
        var emails = value.split(',');
        var re = new RegExp(/^([\w\.\-]+)@([\w\-]+)((\.(\w){2,6})+)$/i);
        for (var i = 0; i < emails.length; i++) {
          if (!re.test($.trim(emails[i]))) {
            return false; 
          } 
        }
        return true;
      }
  );

  $.validator.  
    addMethod("min_date", 
      function(value, element, is_rideshare) {
        if (is_rideshare == "true") {
          return get_datetime_from_datetime_select() > new Date();
        } else {
          return get_date_from_date_select() > new Date();
        }
       }
    );

  $.validator.  
    addMethod("max_date", 
      function(value, element, is_rideshare) {
        var current_time = new Date();
        var maximum_date = new Date(new Date(current_time).setMonth(current_time.getMonth()+6));
        if (is_rideshare == "true") {
          return get_datetime_from_datetime_select() < maximum_date;
        } else {
          return get_date_from_date_select() < maximum_date;
        }
       }
    );  

  $.validator.
    addMethod( "captcha", 
      function(value, element, param) {    
        challengeField = $("input#recaptcha_challenge_field").val();
        responseField = $("input#recaptcha_response_field").val();

        var resp = $.ajax({
              type: "GET",
              url: "signup/check_captcha",
              data: "recaptcha_challenge_field=" + challengeField + "&amp;recaptcha_response_field=" + responseField,
              async: false
        }).responseText;

        if (resp == "success") {
          return true;
        } else {
          Recaptcha.reload();
          return false;
        }
      }
    );

  $.validator.  
    addMethod("required_when_not_neutral_feedback", 
      function(value, element, param) {
        if (value == "") {
          var radioButtonArray = new Array("1", "2", "4", "5"); 
          for (var i = 0; i < radioButtonArray.length; i++) {
            if ($('#grade-' + radioButtonArray[i]).is(':checked')) {
              return false;
            }
          }
        }
        return true; 
       }
    );
  
  $.validator.
    addMethod( "positive_integer", 
      function(value, element, param) {
        var n = ~~Number(value);
        return String(n) === value && n >= 0;
      }
    );

  $.validator.
    addMethod( "minimum_price_required", 
      function(value, element, minimum_price) {
        if (minimum_price == "") {
          return true
        } else {
          return minimum_price <= value*100; 
        }
      }
    );

}

function report_analytics_event(params_array) {
  if (typeof _gaq != 'undefined') {
    _gaq.push(['_trackEvent'].concat(params_array));
    if (secondary_analytics_in_use) {
      _gaq.push(['b._trackEvent'].concat(params_array));
    }
  }
}

// Initialize code that is needed for every view
function initialize_defaults(locale) {
  add_validator_methods();
  translate_validation_messages(locale);
  // This can be used if flash notifications should fade out
  // automatically - currently not used.
  //setTimeout(hideNotice, 5000);
  $('.flash-notifications').click(function() {
    $('.flash-notifications').fadeOut('slow');
  });
  $('#login-toggle-button').click(function() { 
    $('#upper_person_login').focus();
  });
}

function initialize_network_defaults(required_message, email_message) {  
  enableSamePageScroll();
}

function initialize_contact_request_form(required_message, email_message) {
  var validation = {
    rules: {
      "contact_request[email]": {required: true, email: true}
    },
    messages: {
      "contact_request[email]": {required: required_message, email: email_message}
    },
    errorPlacement: function(error, element) {
      error.appendTo(element.parent().parent());
    },
    onkeyup: false,
    onclick: false,
    onfocusout: false,
    onsubmit: true
  }
  $("#new_contact_request_top").validate(validation);
  $("#new_contact_request_bottom").validate(validation);
}

function initialize_update_contact_request_form(country_message, marketplace_type_message, plan_type_message) {
  var validation = {
    rules: {
      "contact_request[country]": {required: true},
      "contact_request[marketplace_type]": {required: true},
      "contact_request[plan_type]": {required: true}
    },
    messages: {
      "contact_request[country]": {required: country_message},
      "contact_request[marketplace_type]": {required: marketplace_type_message},
      "contact_request[plan_type]": {required: plan_type_message}
    },
    errorPlacement: function(error, element) {
      if (element.attr("name") == "contact_request[plan_type]")  {
        error.appendTo(element.parent().parent());
      } else {
        error.insertAfter(element);
      }
    },
    onkeyup: false,
    onclick: false,
    onfocusout: false,
    onsubmit: true
  }
  $("#new_contact_request_top").validate(validation);
  $("#new_contact_request_bottom").validate(validation);
}

var hideNotice = function() {
  $('.flash-notifications').fadeOut('slow');
}

function initialize_user_feedback_form() {
  form_id = "#new_feedback";
  $(form_id).validate({
    rules: {
      "feedback[email]": {required: false, email: true},
      "feedback[content]": {required: true, minlength: 1}
    }
  });
}

function initialize_email_members_form() {
  form_id = "#new_member_email";
  auto_resize_text_areas("email_members_text_area");
  $(form_id).validate({
    rules: {
      "email[subject]": {required: true, minlength: 2},
      "email[content]": {required: true, minlength: 2}
    }
  });
}

function initialize_feedback_tab() {
  $('.feedback_div').tabSlideOut({
    tabHandle: '.handle',                     //class of the element that will become your tab
    pathToTabImage: '/assets/feedback_handles.png',
    imageHeight: '122px',                     //height of tab image           //Optionally can be set using css
    imageWidth: '40px',                       //width of tab image            //Optionally can be set using css
    tabLocation: 'left',                      //side of screen where tab lives, top, right, bottom, or left
    speed: 300,                               //speed of animation
    action: 'click',                          //options: 'click' or 'hover', action to trigger animation
     topPos: '200px',                          //position from the top/ use if tabLocation is left or right
    fixedPosition: true
  });
}

function initialize_login_form(password_forgotten) {
  if (password_forgotten == true) {
    $('#password_forgotten').slideDown('fast');
    $("html, body").animate({ scrollTop: $(document).height() }, 1000);
    $('input.request_password').focus();
  }
  $('#password_forgotten_link').click(function() { 
    $('#password_forgotten').slideToggle('fast');
    $("html, body").animate({ scrollTop: $(document).height() }, 1000);
    $('input.request_password').focus();
  });
  $('#login_form input.text_field:first').focus();
}

function initialize_new_organization_form(show_merchant_registration, locale) {
  if (show_merchant_registration) {
    $('#merchant_details').slideToggle('fast');
  }
  $(':radio[name="organization[merchant_registration]"]').change(function() { 
    $('#merchant_details').slideToggle('fast');
  });
  
  var form_id = "#organization_form";
  $(form_id).validate({
    rules: {
      "organization[name]": {required: true, minlength: 3, maxlength: 80},
      "organization[company_id]": {minlength: 9, maxlength: 9},
      "organization[email]": {email: true},
      "organization[website]": {minlength: 5},
      "organization[phone_number]": {minlength: 6},
      "organization[address]": {minlength: 6},
      "organization[logo]": { accept: "(jpe?g|gif|png)" },
    },
    messages: {
    },
    onkeyup: false, //Only do validations when form focus changes
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);  
    }
  });

}



function select_listing_form_menu_link(link, locale, attribute_hash, listing_form_menu_titles, ordered_attributes, selected_attributes) {
  if (link.hasClass('option')) {
    selected_attributes[link.parent().attr('name')] = link.attr('name');
  } else {
    selected_attributes[link.parent().attr('name')] = null;
    index_found = false;
    for (i = 0; i < ordered_attributes.length; i++) {
      if (ordered_attributes[i] == link.parent().attr('name')) {
        index_found = true;
      }
      if (index_found == true) {
        selected_attributes[ordered_attributes[i]] = null;
      }
    }
  }
  update_listing_form_view(locale, attribute_hash, listing_form_menu_titles, ordered_attributes, selected_attributes);
}

// Return true if the menu for the given attribute should be shown in
// the listing form in this community.
function menu_applicable(attribute, selected_attributes, attribute_hash) {
  if (attribute == "listing_type") {
    var values = attribute_hash;
  } else if (attribute == "category") {
    var values = attribute_hash[selected_attributes["listing_type"]];
  } else if (attribute == "subcategory" || attribute == "share_type") {
    if ((attribute_hash[selected_attributes["listing_type"]] == undefined) || (attribute_hash[selected_attributes["listing_type"]][selected_attributes["category"]] == undefined)) {
      values == undefined;
    } else {
      var values = attribute_hash[selected_attributes["listing_type"]][selected_attributes["category"]][attribute];
    }
  }
  if (values == undefined) {
    return false;
  } else {
    var value_array = null;
    if ($.isArray(values) == true) {
      value_array = values; 
    } else {
      value_array = get_keys(values);
    }
    if (value_array.length < 1) {
      return false;
    } else if (value_array.length == 1) {
      selected_attributes[attribute] = value_array[0];
      return false;
    } else {
      return true;
    }
  }
}

function get_keys(values) {
   var keys = [];
   for(var key in values){
      keys.push(key);
   }
   return keys;
}

function update_listing_form_view(locale, attribute_hash, listing_form_menu_titles, ordered_attributes, selected_attributes) {
  $('a.selected').addClass('hidden');
  $('a.option').addClass('hidden');
  $('.form-fields').html("");
  
  $('.selected-group').each(function() {
    if (selected_attributes[$(this).attr('name')] != null) {
      $('a.selected[name=' + selected_attributes[$(this).attr('name')] + ']').removeClass('hidden');
    }
  }); 
  
  var title = "";
  
  if ((selected_attributes["listing_type"] != null) || !menu_applicable("listing_type", selected_attributes, attribute_hash))  {
    if ((selected_attributes["category"] != null) || !menu_applicable("category", selected_attributes, attribute_hash)) {
      if ((selected_attributes["subcategory"] != null) || !menu_applicable("subcategory", selected_attributes, attribute_hash)) {
        if ((selected_attributes["share_type"]  != null) || !menu_applicable("share_type", selected_attributes, attribute_hash)) {
          $('.form-fields').removeClass('hidden');
          var new_listing_path = '/' + locale + '/listings/new';
          $.get(new_listing_path, selected_attributes, function(data) {
            $('.form-fields').html(data);
          });
        } else {
          $('.option-group[name=share_type]').children().each(function() {
            if ($.inArray($(this).attr('name'), attribute_hash[selected_attributes["listing_type"]][selected_attributes["category"]]["share_type"]) > -1) {
              $(this).removeClass('hidden');
            }
          });
          title = listing_form_menu_titles["share_type"][selected_attributes["listing_type"]];
        }
      } else {
        $('.option-group[name=subcategory]').children().each(function() {
          if ($.inArray($(this).attr('name'), attribute_hash[selected_attributes["listing_type"]][selected_attributes["category"]]["subcategory"]) > -1) {
            $(this).removeClass('hidden');
          }
        });
        title = listing_form_menu_titles["subcategory"][selected_attributes["category"]];
      }
    } else {
      $('.option-group[name=category]').children().each(function() {
        if (attribute_hash[selected_attributes["listing_type"]][$(this).attr('name')] != null) {
          $(this).removeClass('hidden');
        }
      });
      if (listing_form_menu_titles["category"][selected_attributes["listing_type"]] == undefined) {
        title = listing_form_menu_titles["category"]["default"];
      } else {
        title = listing_form_menu_titles["category"][selected_attributes["listing_type"]];
      }
    }
  } else {
    title = listing_form_menu_titles["listing_type"];
    $('.option-group[name=listing_type]').children().each(function() {
      $(this).removeClass('hidden');
    });
  }
  
  $('h2.listing-form-title').html(title);
}

// Initialize the listing type & category selection part of the form
function initialize_new_listing_form_selectors(locale, attribute_hash, listing_form_menu_titles) {
  var ordered_attributes = ["listing_type", "category", "subcategory", "share_type"];
  var selected_attributes = {"listing_type": null, "category": null, "subcategory": null, "share_type": null};
  
  update_listing_form_view(locale, attribute_hash, listing_form_menu_titles, ordered_attributes, selected_attributes);
  
  $('.new-listing-form').find('a.select').click(
    function() {
      select_listing_form_menu_link($(this), locale, attribute_hash, listing_form_menu_titles, ordered_attributes, selected_attributes);
    }
  );
  
}

// Initialize the actual form fields
function initialize_new_listing_form(fileDefaultText, fileBtnText, locale, share_type_message, date_message, is_rideshare, is_offer, listing_id, price_required, price_message, minimum_price, minimum_price_message) {
  
  $('#help_valid_until_link').click(function() { $('#help_valid_until').lightbox_me({centered: true, zIndex: 1000000}); });
  $('input.title_text_field:first').focus();
  
  $(':radio[name=valid_until_select]').change(function() {
    if ($(this).val() == "for_now") {
      $('select.listing_datetime_select').attr('disabled', 'disabled');
    } else {
      $('select.listing_datetime_select').removeAttr('disabled');
    }
  });
  
  form_id = (listing_id == "false") ? "#new_listing" : ("#edit_listing_" + listing_id);
  
  // Change the origin and destination requirements based on listing_type
  var rs = null;
  if (is_rideshare == "true") {
    rs = true;
  } else {
    rs = false;
  }
  
  // Is price required?
  var pr = null;
  if (price_required == "true") {
    pr = true;
  } else {
    pr = false;
  }
  
  $(form_id).validate({
    errorPlacement: function(error, element) {
      if (element.attr("name") == "listing[listing_images_attributes][0][image]")  {
        error.appendTo(element.parent());
      } else if (element.attr("name") == "listing[valid_until(1i)]") {
        error.appendTo(element.parent());
      } else if (element.attr("name") == "listing[price]") {
        error.appendTo(element.parent());
      } else {
        error.insertAfter(element);
      }
    },
    debug: false,
    rules: {
      "listing[title]": {required: true},
      "listing[origin]": {required: rs, address_validator: true},
      "listing[destination]": {required: rs, address_validator: true},
      "listing[price]": {required: pr, positive_integer: true, minimum_price_required: minimum_price},
      "listing[listing_images_attributes][0][image]": { accept: "(jpe?g|gif|png)" },
      "listing[valid_until(1i)]": { min_date: is_rideshare, max_date: is_rideshare }
    },
    messages: {
      "listing[valid_until(1i)]": { min_date: date_message, max_date: date_message },
      "listing[price]": { positive_integer: price_message, minimum_price_required: minimum_price_message },
    },
    // Run validations only when submitting the form.
    onkeyup: false,
    onclick: false,
    onfocusout: false,
    onsubmit: true,
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
      report_analytics_event(["listing", "created"]);
    }
  });
  
  set_textarea_maxlength();
  auto_resize_text_areas("listing_description_textarea");
}

function initialize_send_message_form(locale, message_type) {  
  auto_resize_text_areas("text_area");
  $('textarea').focus();
  var form_id = "#new_conversation";
  $(form_id).validate({
    rules: {
      "conversation[title]": {required: true, minlength: 1, maxlength: 120},
      "conversation[message_attributes][content]": {required: true, minlength: 1}
    },
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
      report_analytics_event(["message", "sent", message_type]);
    }
  });  
}

function initialize_reply_form(locale) {
  auto_resize_text_areas("reply_form_text_area");
  $('textarea').focus();
  prepare_ajax_form(
    "#new_message",
    locale, 
    {"message[content]": {required: true, minlength: 1}}
  );
}

function initialize_listing_view(locale) {
  $('#listing-image-link').click(function() { $('#listing-image-lightbox').lightbox_me({centered: true, zIndex: 1000000}); });
  auto_resize_text_areas("listing_comment_content_text_area");
  $('textarea').focus();
  prepare_ajax_form(
    "#new_comment",
    locale, 
    {"comment[content]": {required: true, minlength: 1}}
  );
  
  $('#send_comment_button').click(function() {
    report_analytics_event(["listing", "commented"]);
  });
}

function initialize_accept_transaction_form(commission_percentage, service_fee_vat) {
	auto_resize_text_areas("text_area");
	style_action_selectors();
	
	if (commission_percentage != undefined) {
	  update_transaction_form_price_fields(commission_percentage, service_fee_vat);
  	$(".trigger-focusout").focusout(function(value) {
  	  update_transaction_form_price_fields(commission_percentage, service_fee_vat);
  	});
  }
	
}

function update_transaction_form_price_fields(commission_percentage, service_fee_vat) {
  var total_sum = 0;
  var total_sum_with_vat = 0;
  for (var i = 0; i < $(".field-row").length; i++) {
    var sum = parseInt($(".payment-row-sum-field.row" + i).val());

    var vat = parseInt($(".payment-row-vat-field.row" + i).val());
    if (! vat > 0) { vat = 0;}
    
    row_sum = sum + (sum * vat / 100);
    $(".total-label.row" + i).text(row_sum.toFixed(2) + '\u20AC');
    total_sum += sum;
    total_sum_with_vat += row_sum;
  }
  
  var service_fee_sum = total_sum*commission_percentage/100;
  $("#service-fee-sum").text(service_fee_sum.toFixed(2) + '\u20AC');
  
  service_fee_sum_with_vat = service_fee_sum + (service_fee_sum * service_fee_vat / 100);
  $("#service-fee-total").text(service_fee_sum_with_vat.toFixed(2) + '\u20AC');
  $("#total").text((total_sum_with_vat + service_fee_sum_with_vat).toFixed(2) + '\u20AC');
}

function initialize_confirm_transaction_form() {
  style_action_selectors();
}

function style_action_selectors() {
  $(".conversation-action").each(function() {
    $(this).find('label').hide();
    $(this).find('.conversation-action').each(
      function() {
        $(this).removeClass('hidden');
        $(this).click(
          function() {
            var action = $(this).attr('id');
            $(this).siblings().removeClass('accept').removeClass('reject').removeClass('confirm').removeClass('cancel');
            
            // Show or hide description text
            $(".confirm-description").addClass('hidden');
            $(".cancel-description").addClass('hidden');
            $("." + action + "-description").removeClass('hidden');
            
            // Show or hide price field
            $(".conversation-price").addClass('hidden');
            $("." + action +  "-price").removeClass('hidden');
            
            // Show or hide payout details missing information
            $(".hidden-accept-form").addClass('hidden');
            $(".visible-when-" + action).removeClass('hidden');
            
            $(this).addClass(action);
            $(".conversation-action").find('input:radio[id=' + $(this).attr('name') + ']').attr('checked', true);
            $("#conversation_message_attributes_action").val(action);
            $("#conversation_status").val(action + 'ed');
          }
        );
      }  
    );
  });
}

function initialize_give_feedback_form(locale, grade_error_message, text_error_message) {
  auto_resize_text_areas("text_area");
  $('textarea').focus();
  style_grade_selectors();
  var form_id = "#new_testimonial";
  $(form_id).validate({
    errorPlacement: function(error, element) {
      if (element.attr("name") == "testimonial[grade]") {
        error.appendTo(element.parent().parent());
      }  else {
        error.insertAfter(element);
      }
    },  
    rules: {
      "testimonial[grade]": {required: true},
      "testimonial[text]": {required: true}
    }, 
    messages: {
      "testimonial[grade]": { required: grade_error_message }
    },
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
    }
  });
}

function style_grade_selectors() {
  $(".feedback-grade").each(function() {
    $(this).find('label').hide();
    $(this).find('.grade').each(
      function() {
        $(this).removeClass('hidden');
        $(this).click(
          function() {
            $(this).siblings().removeClass('negative').removeClass('positive');
            $(this).addClass($(this).attr('id'));
            $(".feedback-grade").find('input:radio[id=' + $(this).attr('name') + ']').attr('checked', true);
          }
        );
      }  
    );
  });
}



function initialize_signup_form(locale, username_in_use_message, invalid_username_message, email_in_use_message, captcha_message, invalid_invitation_code_message, name_required, invitation_required) {
  $('#help_invitation_code_link').click(function(link) {
    //link.preventDefault();
    $('#help_invitation_code').lightbox_me({centered: true, zIndex: 1000000 }); 
  });
  $('#terms_link').click(function(link) {
    link.preventDefault();
    $('#terms').lightbox_me({ centered: true, zIndex: 1000000 }); 
  });
  var form_id = "#new_person";
  //name_required = (name_required == 1) ? true : false
  $(form_id).validate({
    errorPlacement: function(error, element) {
      if (element.attr("name") == "person[terms]") {
        error.appendTo(element.parent().parent());
      } else if (element.attr("name") == "recaptcha_response_field") {
        error.appendTo(element.parent().parent().parent().parent().parent().parent().parent().parent().parent());
      } else {
        error.insertAfter(element);
      }  
    },
    rules: {
      "person[username]": {required: true, minlength: 3, maxlength: 20, valid_username: true, remote: "/people/check_username_availability"},
      "person[given_name]": {required: name_required, maxlength: 30},
      "person[family_name]": {required: name_required, maxlength: 30},
      "person[email]": {required: true, email: true, remote: "/people/check_email_availability_and_validity"},
      "person[terms]": "required",
      "person[password]": { required: true, minlength: 4 },
      "person[password2]": { required: true, minlength: 4, equalTo: "#person_password1" },
      "recaptcha_response_field": {required: true, captcha: true },
      "invitation_code": {required: invitation_required, remote: "/people/check_invitation_code"}
    },
    messages: {
      "recaptcha_response_field": { captcha: captcha_message },
      "person[username]": { valid_username: invalid_username_message, remote: username_in_use_message },
      "person[email]": { remote: email_in_use_message },
      "invitation_code": { remote: invalid_invitation_code_message }
    },
    onkeyup: false, //Only do validations when form focus changes to avoid exessive ASI calls
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
      report_analytics_event(['user', "signed up", "normal form"]);
    }
  });  
}

function initialize_terms_form() {
  $('#terms_link').click(function(link) {
    link.preventDefault();
    $('#terms').lightbox_me({ centered: true, zIndex: 1000000 }); 
  });
}

function initialize_mangopay_terms_lightbox() {
  $('#mangopay_terms_link').click(function(link) {
    link.preventDefault();
    $('#mangopay_terms').lightbox_me({ centered: true, zIndex: 1000001 }); 
  });
}


function initialize_update_profile_info_form(locale, person_id, name_required) {
  auto_resize_text_areas("update_profile_description_text_area");
  $('input.text_field:first').focus();
  var form_id = "#edit_person_" + person_id;
  $(form_id).validate({
    rules: {
      "person[street_address]": {required: false, address_validator: true},
      "person[given_name]": {required: name_required, maxlength: 30},
      "person[family_name]": {required: name_required, maxlength: 30},
      "person[phone_number]": {required: false, maxlength: 25},
      "person[image]": { accept: "(jpe?g|gif|png)" }
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

function initialize_update_notification_settings_form(locale, person_id) {
  var form_id = "#edit_person_" + person_id;
  $(form_id).validate({
    submitHandler: function(form) {
      disable_and_submit(form_id, form, "false", locale);
    }
  });  
}

function initialize_update_account_info_form(locale, change_text, cancel_text, email_in_use_message) {
  $('#account_email_link').toggle(
    function() {
      $('#account_email_form').show();
      $(this).text(cancel_text);
      $('#person_email').focus();
    },
    function() {
      $('#account_email_form').hide();
      $(this).text(change_text);
    }
  );
  $('#account_password_link').toggle(
    function() {
      $('#account_password_form').show();
      $(this).text(cancel_text);
      $('#person_password').focus();
    },
    function() {
      $('#account_password_form').hide();
      $(this).text(change_text);
    }
  );
  var email_form_id = "#email_form";
  $(email_form_id).validate({
    rules: {
      "person[email]": {required: true, email: true, remote: "/people/check_email_availability"}
    },
    messages: {
      "person[email]": { remote: email_in_use_message }
    },
    submitHandler: function(form) {
      disable_and_submit(email_form_id, form, "false", locale);
    }
  });
  var password_form_id = "#password_form";
  $(password_form_id).validate({
    rules: {
      "person[password]": { required: true, minlength: 4 },
      "person[password2]": { required: true, minlength: 4, equalTo: "#person_password" }
    },
    submitHandler: function(form) {
      disable_and_submit(password_form_id, form, "false", locale);
    }
  });  
}

function initialize_reset_password_form() {
  var password_form_id = "#new_person";
  $(password_form_id).validate({
    errorPlacement: function(error, element) {
      error.insertAfter(element);
    },
    rules: {
      "person[password]": { required: true, minlength: 4 },
      "person[password_confirmation]": { required: true, minlength: 4, equalTo: "#person_password" }
    },
    submitHandler: function(form) {
      disable_and_submit(password_form_id, form, "false", locale);
    }
  });  
}

function initialize_profile_view(badges, profile_id, show_closed) {
  $('#load-more-listings').click(function() { 
    request_path = profile_id + "/listings";
    if (show_closed == true) {
      request_path += "?show_closed=true";
    }
    $.get(request_path, function(data) {
      $('#profile-listings-list').html(data);
    });
    return false;
  });
  
  $('#load-more-testimonials').click(function() { 
    request_path = profile_id + "/testimonials";
    $.get(request_path, {per_page: 200, page: 1}, function(data) {
      $('#profile-testimonials-list').html(data);
    });
    return false;
  });
  
  
  // The code below is not used in early 3.0 version, but part of it will probably be used again soon, so kept here.
  $('#description_preview_link').click(function() { 
    $('#profile_description_preview').hide();
    $('#profile_description_full').show(); 
  });
  $('#description_full_link').click(function() { 
    $('#profile_description_preview').show();
    $('#profile_description_full').hide(); 
  });
  $('#badges_description_link').click(function() { $('#badges_description').lightbox_me({centered: true}); });
  $('#trustcloud_description_link').click(function() { $('#trustcloud_description').lightbox_me({centered: true}); });
  for (var i = 0; i < badges.length; i++) {
    $('#' + badges[i] + '_description_link').click(function(badge) {
      badge.preventDefault();
      $('#' + badge.currentTarget.id + '_target').lightbox_me({centered: true});
    });
  }
}

function initialize_homepage_news_items(news_item_ids) {
  for (var i = 0; i < news_item_ids.length; i++) {
    $('#news_item_' + news_item_ids[i] + '_content').click(function(news_item) {
      $('#' + news_item.currentTarget.id + '_div_preview').hide();
      $('#' + news_item.currentTarget.id + '_div_full').show(); 
    });
    $('#news_item_' + news_item_ids[i] + '_content_div').click(function(news_item) { 
      $('#' + news_item.currentTarget.id + '_preview').show();
      $('#' + news_item.currentTarget.id + '_full').hide();
    });
  }
}

function initialize_homepage(filters_in_use) {
  
  if (filters_in_use) { 
    // keep filters dropdown open in mobile view if any filters selected
    $('#filters-toggle').click();
  }
  
  $('#feed-filter-dropdowns select').change(
    function() {
      
      // It's challenging to get the pageless right if reloading just the small part so reload all page
      // instead of the method below that would do AJAX update (currently works only partially)
      //reload_homepage_view();
      
      $("#homepage-filters").submit();    
      
    }
  );
  
  // make map/list button change the value in the filter form and submit the form
  // in order to keep all filter values combinable and remembered
  $('.map-button').click(
    function() {
      $("#hidden-map-toggle").val(true);
      $("#homepage-filters").submit();
      return false;
    }
  );
  $('.list-button').click(
    function() {
      $("#hidden-map-toggle").val(undefined);
      $("#homepage-filters").submit();
      return false;
    }
  );
}

function reload_homepage_view() {
  // Make AJAX request based on selected items
  var request_path = window.location.toString();
  var filters = {};
  filters["share_type"] = $('#share_type').val();
  filters["category"] = $('#listing_category').val();
  
  // Update request path with updated query params
  for (var key in filters) {
    request_path = UpdateQueryString(key, filters[key], request_path);
  }
  
  $.get(request_path, filters, function(data) {
    $('.homepage-feed').html(data);
    history.pushState(null, document.title, request_path);
  });
}

function initialize_invitation_form(locale, email_error_message) {
  $("#new_invitation").validate({
    rules: {
      "invitation[email]": {required: true, email_list: true},
      "invitation[message]": {required: false, maxlength: 5000}
    },
    messages: {
      "invitation[email]": { email_list: email_error_message}
    },
    onkeyup: false,
    onclick: false,
    onfocusout: false,
    onsubmit: true,
    submitHandler: function(form) {
      disable_and_submit("#new_invitation", form, "false", locale);
    }
  });
}


function initialize_private_community_defaults(locale, feedback_default_text) {
  add_validator_methods();
  translate_validation_messages(locale);
  $('select.language_select').selectmenu({style: 'dropdown', width: "100px"});
  $('#close_notification_link').click(function() { $('#notifications').slideUp('fast'); });
  // Make sure that Sharetribe cannot be used if js is disabled
  $('.wrapper').addClass('js_enabled');
}

function initialize_private_community_homepage(username_or_email_default_text, password_default_text) {
  $('#password_forgotten_link').click(function() { 
    $('#password_forgotten').slideToggle('fast'); 
    $('input.request_password').focus();
  });
  $('#person_login').watermark(username_or_email_default_text, {className: 'default_text'});
  $('#person_password').watermark(password_default_text, {className: 'default_text'});
  $('.wrapper').addClass('js_enabled');
}

function initialize_admin_edit_tribe_form(locale, community_id) {
  auto_resize_text_areas("new_tribe_text_area");
  translate_validation_messages(locale);
  $('#invite_only_help_text_link').click(function() { $('#invite_only_help_text').lightbox_me({centered: true}); });
  var form_id = "#edit_community_" + community_id;
  $(form_id).validate({
     rules: {
       "community[name]": {required: true, minlength: 2, maxlength: 50},
       "community[slogan]": {required: true, minlength: 2, maxlength: 100},
       "community[description]": {required: true, minlength: 2}
     },
     submitHandler: function(form) {
       disable_and_submit(form_id, form, "false", locale);
     }
   });
}

function initialize_admin_edit_tribe_look_and_feel_form(locale, community_id, invalid_color_code_message) {
  translate_validation_messages(locale);
  var form_id = "#edit_community_" + community_id;
  $(form_id).validate({
     rules: {
       "community[custom_color1]": {required: false, minlength: 6, maxlength: 6, regex: "^([a-fA-F0-9]+)?$"}
     },
     messages: {
      "community[custom_color1]": { regex: invalid_color_code_message }
    },
     submitHandler: function(form) {
       disable_and_submit(form_id, form, "false", locale);
     }
   });
}

function initialize_new_community_membership_form(email_invalid_message, invitation_required, invalid_invitation_code_message) {
  $('#help_invitation_code_link').click(function(link) {
    $('#help_invitation_code').lightbox_me({centered: true, zIndex: 1000000 }); 
  });
  $('#terms_link').click(function(link) {
    link.preventDefault();
    $('#terms').lightbox_me({ centered: true, zIndex: 1000000 }); 
  });
  $('#new_community_membership').validate({
    errorPlacement: function(error, element) {
      if (element.attr("name") == "community_membership[consent]") {
        error.appendTo(element.parent().parent());
      } else {
        error.insertAfter(element);
      }
    },
    rules: {
      "community_membership[email]": {required: true, email: true, remote: "/people/check_email_availability_and_validity"},
      "community_membership[consent]": {required: true},
      "invitation_code": {required: invitation_required, remote: "/people/check_invitation_code"}
    },
    messages: {
      "community_membership[email]": { remote: email_invalid_message },
      "invitation_code": { remote: invalid_invitation_code_message }
    },
  });    
}

function set_textarea_maxlength() {
  var ignore = [8,9,13,33,34,35,36,37,38,39,40,46];
  var eventName = 'keypress';
  $('textarea[maxlength]')
    .live(eventName, function(event) {
      var self = $(this),
          maxlength = self.attr('maxlength'),
          code = $.data(this, 'keycode');
      if (maxlength && maxlength > 0) {
        return ( self.val().length < maxlength
                 || $.inArray(code, ignore) !== -1 );
 
      }
    })
    .live('keydown', function(event) {
      $.data(this, 'keycode', event.keyCode || event.which);
    });
}


function get_date_from_date_select() {
  year = $('#listing_valid_until_1i').val();
  month = $('#listing_valid_until_2i').val();
  day = $('#listing_valid_until_3i').val();
  date = new Date(year,month-1,day,"23","59","58");
  return date;
}

function get_datetime_from_datetime_select() {
  year = $('#listing_valid_until_1i').val();
  month = $('#listing_valid_until_2i').val();
  day = $('#listing_valid_until_3i').val();
   hours= $('#listing_valid_until_4i').val();
  minutes = $('#listing_valid_until_5i').val();
  date = new Date(year,month-1,day,hours,minutes);
  return date;
}

// Credits to ellemayo's StackOverflow answer: http://stackoverflow.com/a/11654596/150382
function UpdateQueryString(key, value, url) {
    if (!url) url = window.location.href;
    var re = new RegExp("([?|&])" + key + "=.*?(&|#|$)", "gi");

    if (url.match(re)) {
        if (value)
            return url.replace(re, '$1' + key + "=" + value + '$2');
        else
            return url.replace(re, '$2');
    }
    else {
        if (value) {
            var separator = url.indexOf('?') !== -1 ? '&' : '?',
                hash = url.split('#');
            url = hash[0] + separator + key + '=' + value;
            if (hash[1]) url += '#' + hash[1];
            return url;
        }
        else
            return url;
    }
}

//FB Popup from: http://stackoverflow.com/questions/4491433/turn-omniauth-facebook-login-into-a-popup
// Didn't work now, but I leave here to make things faster if want to invesetigate more.

// function popupCenter(url, width, height, name) {
//   var left = (screen.width/2)-(width/2);
//   var top = (screen.height/2)-(height/2);
//   return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top);
// }
// 
// $("a.popup").click(function(e) {
//   alert("HOE");
//   popupCenter($(this).attr("href"), $(this).attr("data-width"), $(this).attr("data-height"), "authPopup");
//   e.stopPropagation(); return false;
// });

function closeAllToggleMenus() {
  $('.toggle-menu').addClass('hidden');
  $('.toggle-menu-feed-filters').addClass('hidden');
  $('.toggle').removeClass('toggled');
  $('.toggle').removeClass('toggled-logo');
  $('.toggle').removeClass('toggled-full-logo');
  $('.toggle').removeClass('toggled-icon-logo');
  $('.toggle').removeClass('toggled-no-logo');
}

function toggleDropdown(event_target) {
  
  //Gets the target toggleable menu from the link's data-attribute
  var target = event_target.attr('data-toggle');
  var logo_class = event_target.attr('data-logo_class');
  
  if ($(target).hasClass('hidden')) {
    // Opens the target toggle menu
    closeAllToggleMenus();
    $(target).removeClass('hidden');
    if(event_target.hasClass('select-tribe')) {
      event_target.addClass('toggled-logo');
      if (logo_class != undefined) {
        event_target.addClass(logo_class);
      }
    } else {
      event_target.addClass('toggled');
    }
  } else {
    // Closes the target toggle menu
    $(target).addClass('hidden');
    event_target.removeClass('toggled');
    event_target.removeClass('toggled-logo');
    if (logo_class != undefined) {
      event_target.removeClass(logo_class);
    }
  }
  
}

$(function(){
  
  $('.toggle').click( function(event){
    event.stopPropagation();
    toggleDropdown($(this));
  });
  
  $('.toggle-menu').click( function(event){
    event.stopPropagation();
  });
  
  $('.toggle-menu-feed-filters').click( function(event){
    event.stopPropagation();
  });

  // All dropdowns are collapsed when clicking outside dropdown area
  $(document).click( function(){
    closeAllToggleMenus();
  });
  
});

function enableSamePageScroll() {
  function filterPath(string) {
  return string
    .replace(/^\//,'')
    .replace(/(index|default).[a-zA-Z]{3,4}$/,'')
    .replace(/\/$/,'');
  }
  var locationPath = filterPath(location.pathname);
  var scrollElem = scrollableElement('html', 'body');
 
  $('a[href*=#]').each(function() {
    var thisPath = filterPath(this.pathname) || locationPath;
    if (  locationPath == thisPath
    && (location.hostname == this.hostname || !this.hostname)
    && this.hash.replace(/#/,'') ) {
      var $target = $(this.hash), target = this.hash;
      if (target) {
        var targetOffset = $target.offset().top;
        $(this).click(function(event) {
          event.preventDefault();
          $(scrollElem).animate({scrollTop: targetOffset}, 400, function() {
            location.hash = target;
          });
        });
      }
    }
  });
 
  // use the first element that is "scrollable"
  function scrollableElement(els) {
    for (var i = 0, argLength = arguments.length; i <argLength; i++) {
      var el = arguments[i],
          $scrollElement = $(el);
      if ($scrollElement.scrollTop()> 0) {
        return el;
      } else {
        $scrollElement.scrollTop(1);
        var isScrollable = $scrollElement.scrollTop()> 0;
        $scrollElement.scrollTop(0);
        if (isScrollable) {
          return el;
        }
      }
    }
    return [];
  }
 
}