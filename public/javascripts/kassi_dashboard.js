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
    			var personal_email_endings = ["hotmail.com","gmail.com","yahoo.com"]
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

function initialize_new_tribe_form(locale, invalid_domain_message, domain_in_use_message) {
  var form_id = "#new_community"
  $(form_id).validate({
    errorPlacement: function(error, element) {
			if (element.attr("name") == "community[domain]") {
				error.appendTo(element.parent());
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
		},
		messages: {
			"community[domain]": { valid_domain: invalid_domain_message, remote: domain_in_use_message },
		},
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "false", locale);
		}
	});
}

function initialize_signup_form(locale, username_in_use_message, invalid_username_message, email_in_use_message, invalid_email_ending_message, valid_email_ending_required) {
	$('#terms_link').click(function() { $('#terms').lightbox_me({centered: true}); });
	$("input[type=checkbox]").uniform();
	var form_id = "#new_person"
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
      "person[username]": {required: true, minlength: 3, maxlength: 20, valid_username: true},
      "person[given_name]": {required: true, maxlength: 30},
      "person[family_name]": {required: true, maxlength: 30},
      "person[email]": {required: true, email: true, valid_email_ending_required: valid_email_ending_required},
      "person[terms]": "required",
      "person[password]": { required: true, minlength: 4 },
      "person[password2]": { required: true, minlength: 4, equalTo: "#person_password" }
		},
		messages: {
			"person[username]": { valid_username: invalid_username_message, remote: username_in_use_message },
			"person[email]": { valid_email_ending_required: invalid_email_ending_message, remote: email_in_use_message }
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

function disable_and_submit(form_id, form, ajax, locale) {
	$(form_id + ' input[type=submit]').attr('disabled', 'disabled');
	jQuery.getJSON('/javascripts/locales/' + locale + '.json', function(json) {
	  $(form_id + ' input[type=submit]').val(json.please_wait);
	});
	if (ajax == "true") {
		$(form).ajaxSubmit();
	} else {
  	form.submit();
	}	
}

function auto_resize_text_areas() {
	$('textarea').autoResize({
	    // On resize:
	    onResize : function() {
	        $(this).css({opacity:0.8});
	    },
	    // After resize:
	    animateCallback : function() {
	        $(this).css({opacity:1});
	    },
	    // Quite slow animation:
	    animateDuration : 300
	    // More extra space:
	});
	$('textarea').keydown();
}