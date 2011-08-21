// Custom Javascript functions for Kassi
// Add custom validation methods
$.validator.
	addMethod( "accept", 
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
			maximum_date = new Date((current_time.getFullYear() + 1),current_time.getMonth(),current_time.getDate(),23,59,59);
			if (is_rideshare == "true") {
				// alert ("Datetime select: " + get_datetime_from_datetime_select() + "\n Max date: " + maximum_date);
				//alert ("Max date: " + maximum_date);
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

      if (resp == "success")
      {
        return true;
      }
        else
      {
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


// Initialize code that is needed for every view
function initialize_defaults(default_text, feedback_default_text, locale) {
  translate_validation_messages(locale);
	$('input.search_field').watermark(default_text, {className: 'default_text'});
	$("select.language_select").uniform();
	$('#close_notification_link').click(function() { $('#notifications').slideUp('fast'); });
	// Make sure that Kassi cannot be used if js is disabled
	$('.wrapper').addClass('js_enabled');
	initialize_feedback_tab();
	$('textarea.feedback').watermark(feedback_default_text, {className: 'default_textarea_text'});
	var form_id = "#new_feedback";
	$(form_id).validate({
		rules: {
			"feedback[content]": {required: true, minlength: 1}
		},
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "true", locale);
		}
	});
}

function initialize_feedback_tab() {
  $('.feedback_div').tabSlideOut({
  	tabHandle: '.handle',                     //class of the element that will become your tab
    pathToTabImage: '/images/feedback_handles.png',
	imageHeight: '122px',                     //height of tab image           //Optionally can be set using css
    imageWidth: '40px',                       //width of tab image            //Optionally can be set using css
    tabLocation: 'left',                      //side of screen where tab lives, top, right, bottom, or left
    speed: 300,                               //speed of animation
    action: 'click',                          //options: 'click' or 'hover', action to trigger animation
   	topPos: '200px',                          //position from the top/ use if tabLocation is left or right
    fixedPosition: true
  });
}

function initialize_login_form() {
	$('#password_forgotten_link').click(function() { 
		$('#password_forgotten').slideToggle('fast'); 
		$('input.request_password').focus();
	});
  $('#login_form input.text_field:first').focus();
}

function initialize_new_listing_form(fileDefaultText, fileBtnText, locale, checkbox_message, date_message, is_rideshare, is_offer, listing_id, address_validator) {	
	$('#help_tags_link').click(function() { $('#help_tags').lightbox_me({centered: true}); });
	$('#help_share_type_link').click(function() { $('#help_share_type').lightbox_me({centered: true}); });
	$('#help_valid_until_link').click(function() { $('#help_valid_until').lightbox_me({centered: true}); });
	$('input.title_text_field:first').focus();
	$("select.listing_date_select, input[type=checkbox], input[type=file], input[type=radio]").uniform({
		selectClass: 'selector2',
		fileDefaultText: fileDefaultText, 
		fileBtnText: fileBtnText
	});
	$("select.visibility_select").uniform({selectClass: 'selector3'});
	$(':radio[name=valid_until_select]').change(function() {
		if ($(this).val() == "for_now") {
			$('select.listing_date_select').attr('disabled', 'disabled');
			$('selector2').addClass('disabled');
			$("label[for='for_now_radio_button']").removeClass('disabled_grey');
		} else {
			$('select.listing_date_select').removeAttr('disabled');
			$('selector2').removeClass('disabled');
			$("label[for='for_now_radio_button']").addClass('disabled_grey');
		}
		$.uniform.update("select.listing_date_select");
	});
	form_id = (listing_id == "false") ? "#new_listing" : ("#edit_listing_" + listing_id);
	
	// Change the origin and destination requirements based on listing_type
	var rs = null;
	if (is_rideshare == "true") {
		rs = true;
	} else {
		rs = false;
	}
	
	$(form_id).validate({
		errorPlacement: function(error, element) {
			if (element.attr("name") == "listing[share_type_attributes][]") {
				error.appendTo(element.parent().parent().parent().parent().parent().parent());
			} else if (element.attr("name") == "listing[listing_images_attributes][0][image]")	{
				error.appendTo(element.parent().parent());
			} else if (element.attr("name") == "listing[valid_until(1i)]") {
				if (is_rideshare == "true" || is_offer == "true") {
					error.appendTo(element.parent().parent().parent());
				} else {	
					error.appendTo(element.parent().parent());
				}
			} else {
				error.insertAfter(element);
			}
		},
		debug: false,
		rules: {
			"listing[title]": {required: true},
			"listing[origin]": {required: rs, address_validator: true},
			"listing[destination]": {required: rs, address_validator: true},
			"listing[share_type_attributes][]": {required: true, minlength: 1},
			"listing[listing_images_attributes][0][image]": { accept: "(jpe?g|gif|png)" },
			"listing[valid_until(5i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(4i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(3i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(2i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(1i)]": { min_date: is_rideshare, max_date: is_rideshare }
		},
		messages: {
			"listing[share_type_attributes][]": { required: checkbox_message },
			"listing[valid_until(1i)]": { min_date: date_message, max_date: date_message },
			"listing[valid_until(2i)]": { min_date: date_message, max_date: date_message  },
			"listing[valid_until(3i)]": { min_date: date_message, max_date: date_message  },
			"listing[valid_until(4i)]": { min_date: date_message, max_date: date_message  },
			"listing[valid_until(5i)]": { min_date: date_message, max_date: date_message  }
		},
		 // Run validations only when submitting the form.
		 onkeyup: false,
         onclick: false,
         onfocusout: false,
		 onsubmit: true,
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "false", locale);
		}
	});	
	set_textarea_maxlength();
	auto_resize_text_areas();
}

function initialize_send_message_form(default_text, locale) {
	auto_resize_text_areas();
	$('textarea').watermark(default_text, {className: 'default_textarea_text'});
	$('textarea').focus();
	var form_id = "#new_conversation"
	$(form_id).validate({
		rules: {
			"conversation[message_attributes][content]": {required: true, minlength: 1}
		},
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "false", locale);
		}
	});	
}

function initialize_reply_form(locale) {
	auto_resize_text_areas();
	$('textarea').focus();
	var form_id = "#new_message"
	$(form_id).validate({
		rules: {
			"message[content]": {required: true, minlength: 1}
		},
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "true", locale);
		}
	});	
}

function initialize_comment_form(locale) {
	auto_resize_text_areas();
	var form_id = "#new_comment"
	$(form_id).validate({
		rules: {
			"comment[content]": {required: true, minlength: 1}
		},
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "true", locale);
		}
	});
}

function initialize_give_feedback_form(locale, grade_error_message, text_error_message) {
	auto_resize_text_areas();
	$('textarea').focus();
	faceGrade.create('.feedback_grade_images');
	var form_id = "#new_testimonial"
	$(form_id).validate({
		errorPlacement: function(error, element) {
			if (element.attr("name") == "testimonial[text]") {
				error.appendTo(element.parent());
			} else {
				error.appendTo(element.parent().parent().parent());
			}	
		},	
		rules: {
			"testimonial[grade]": {required: true},
			"testimonial[text]": {required_when_not_neutral_feedback: true}
		}, 
		messages: {
			"testimonial[grade]": { required: grade_error_message },
			"testimonial[text]": { required_when_not_neutral_feedback: text_error_message }
		},
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "false", locale);
		}
	});
}

function initialize_signup_form(locale, username_in_use_message, invalid_username_message, email_in_use_message, captcha_message, invalid_invitation_code_message, name_required, invitation_required) {
	$('#help_captcha_link').click(function() { $('#help_captcha').lightbox_me({centered: true}); });
	$('#help_invitation_code_link').click(function() { $('#help_invitation_code').lightbox_me({centered: true}); });
	$('#terms_link').click(function() { $('#terms').lightbox_me({centered: true}); });
	$("input[type=checkbox]").uniform();
	var form_id = "#new_person"
	//name_required = (name_required == 1) ? true : false
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
      "person[given_name]": {required: name_required, maxlength: 30},
      "person[family_name]": {required: name_required, maxlength: 30},
      "person[email]": {required: true, email: true, remote: "/people/check_email_availability"},
      "person[terms]": "required",
      "person[password]": { required: true, minlength: 4 },
      "person[password2]": { required: true, minlength: 4, equalTo: "#person_password" },
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
		}
	});	
}

function initialize_terms_form() {
	$('#terms_link').click(function() { $('#terms').lightbox_me({centered: true}); });
}

function initialize_update_profile_info_form(locale, person_id, address_validator, name_required) {
	auto_resize_text_areas();
	$('input.text_field:first').focus();
	var form_id = "#edit_person_" + person_id
	$(form_id).validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.parent());
		},	
		rules: {
      "person[street_address]": {required: false, address_validator: true},
			"person[given_name]": {required: name_required, maxlength: 30},
      "person[family_name]": {required: name_required, maxlength: 30},
			// 			"person[postal_code]": {required: false, maxlength: 8},
			// 			"person[city]": {required: false, maxlength: 50},
			"person[phone_number]": {required: false, maxlength: 25}
		},
		 onkeyup: false,
         onclick: false,
         onfocusout: false,
		 onsubmit: true,
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "true", locale);
		}
	});	
}

function initialize_update_notification_settings_form(locale, person_id) {
	$("input[type=checkbox]").uniform();
	var form_id = "#edit_person_" + person_id
	$(form_id).validate({
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "true", locale);
		}
	});	
}

function initialize_update_avatar_form(fileDefaultText, fileBtnText, locale) {
	$("input[type=file]").uniform({
		fileDefaultText: fileDefaultText, 
		fileBtnText: fileBtnText
	});
	var form_id = "#avatar_form";
	$(form_id).validate({
		rules: {
			"file": { required: true, accept: "(jpe?g|gif|png)" } 
		},
		submitHandler: function(form) {
		  disable_and_submit(form_id, form, "true", locale);
		}
	});	
}

function initialize_update_account_info_form(locale, change_text, cancel_text, email_default, pw1_default, pw2_default, email_in_use_message) {
	$('#account_email_link').toggle(
		function() {
			$('#account_email_content').hide();
			$('#account_email_form').show();
			$(this).text(cancel_text);
			$('#person_email').watermark(email_default, {className: 'default_text'});
			$('#person_email').focus();
		},
		function() {
			$('#account_email_content').show();
			$('#account_email_form').hide();
			$(this).text(change_text);
		}
	);
	$('#account_password_link').toggle(
		function() {
			$('#account_password_content').hide();
			$('#account_password_form').show();
			$(this).text(cancel_text);
			$('#person_password').watermark(pw1_default, {className: 'default_text'});
			$('#person_password2').watermark(pw2_default, {className: 'default_text'});
			$('#person_password').focus();
		},
		function() {
			$('#account_password_content').show();
			$('#account_password_form').hide();
			$(this).text(change_text);
		}
	);
	var email_form_id = "#email_form"
	$(email_form_id).validate({
		errorClass: "error_account",
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
	var password_form_id = "#password_form"
	$(password_form_id).validate({
		errorClass: "error_account",
		rules: {
			"person[password]": { required: true, minlength: 4 },
			"person[password2]": { required: true, minlength: 4, equalTo: "#person_password" }
		},
		submitHandler: function(form) {
		  disable_and_submit(password_form_id, form, "false", locale);
		}
	});	
}

function reload_browse_view(link, listing_type, listing_style, locale) {
	type = link.attr("name").split("_")[0];
	title = link.attr("name").split("_")[1];
	allLinks = link.parent().parent().parent().find('a');
	
	// Handle selected items
	if (type == "sharetypes") {
		if (title == "all") {
			link.parent().find('a').removeClass("selected");
			link.addClass("selected");
		} else {
			if (link.hasClass("selected")) {
				link.removeClass("selected");
			} else {
				link.addClass("selected");
				link.parent().find('a[name=' + type + '_all]').removeClass("selected");
			}
		}
		var none_selected = true; 
		link.parent().find('a').each(function() {
			if ($(this).hasClass("selected")) {
				none_selected = false;
			}
		});
		if (none_selected) {
			link.parent().find('a[name=' + type + '_all]').addClass("selected");
		}
		link.parent().find('a').each(function() {
			if ($(this).hasClass("selected")) {
				none_selected = false;
			}
		});
	} else if (type == "tags") {
		if(link.hasClass("selected")) {
			link.removeClass("selected");
		} else {
			link.addClass("selected");
		}
	} else {
		link.parent().find('a').removeClass("selected");
		link.addClass("selected");
	}
	
	// Make AJAX request based on selected items
	var sections = new Array();
	var sectionTypes = ["categories","sharetypes", "tags"];
	for (var i = 0; i < sectionTypes.length; i++) {
		sections[sectionTypes[i]] = new Array();
	}
	allLinks.each(function() {
	  var link_array = $(this).attr("name").split("_");
		link_type = link_array[0];
		link_title = link_array[1];
		if (link_array.length > 2) {
		  link_title += "_" + link_array[2];
		}
		if ($(this).hasClass("selected")) {
			sections[link_type].push(link_title);
		}
	});
	if (listing_style == "map")
		//var request_path = '/' + locale + '/loadmap'
		filtersUpdated(sections['categories'], sections['sharetypes'], sections['tags']);
	else {
		var request_path = '/' + locale + '/load'
		$.get(request_path, { listing_type: listing_type, 'category[]': sections['categories'], 'share_type[]': sections['sharetypes'], 'tag[]': sections['tags'] }, function(data) {
			$('#search_results').html(data);
		});
	}
}

 function initialize_browse_view(listing_type, listing_style, locale) {
       $('#left_link_panel_browse').find('a').click(
       		function() {
            	if (listing_style == 'listing') {
                	$("#search_results").html('<div id="loader"><img src="/images/load.gif" title="load" alt="loading more results" style="margin: 10px auto" /></div>');
                }
                reload_browse_view($(this), listing_type, listing_style, locale);
            }
       );
	   $('#tag_cloud').find('a').click(
		   	function() {
		   		if (listing_style == 'listing') {
					$("#search_results").html('<div id="loader"><img src="/images/load.gif" title="load" alt="loading more results" style="margin: 10px auto" /></div>');
				}
			   	reload_browse_view($(this), listing_type,listing_style, locale);
		   	}
	   );
}

function initialize_profile_view(badges) {
	$('#description_preview_link').click(function() { 
		$('#profile_description_preview').hide();
		$('#profile_description_full').show(); 
	});
	$('#description_full_link').click(function() { 
		$('#profile_description_preview').show();
		$('#profile_description_full').hide(); 
	});
	$('#badges_description_link').click(function() { $('#badges_description').lightbox_me({centered: true}); });
	for (var i = 0; i < badges.length; i++) {
		$('#' + badges[i] + '_description_link').click(function(badge) {
			$('#' + badge.currentTarget.id + '_target').lightbox_me({centered: true});
		});
	}
}

function initialize_profile_feedback_view() {
	$('#help_feedback_link').click(function() { $('#feedback_description').lightbox_me({centered: true}); });
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

// Return listing categories
function categories() {
	return ["item", "favor", "rideshare", "housing"];
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

// Widget that turns radio buttons to Kaapo faces
var faceGrade = {
  create: function(selector) {
    // loop over every element matching the selector
    $(selector).each(function() {
      var $list = $('<div class="grade_link_wrapper"></div>');
      // loop over every radio button in each container
			var id = 1;
      $(this)
        .find('input:radio')
        .each(function(i) {
          var grade = $.trim($(this).parent().text());
          var $item = $('<a href="#"></a>')
            .attr('title', grade)
						.attr('id', '' + id + '')
            .text(grade);
					var $wrapper_div = $('<div></div>');
					$wrapper_div.addClass('feedback_grade_image_' + id);	
					id++;
          faceGrade.addHandlers($item);
					$wrapper_div.append($item);
          $list.append($wrapper_div);
          
          if($(this).is(':checked')) {
            $item.addClass('grade');
          }
        });
        // Hide the original radio buttons
        $(this).append($list).find('label').hide();
    });
  },
  addHandlers: function(item) {
    $(item).click(function(e) {
      // Handle Star click
      var $star = $(this);
      var $allLinks = $(this).parent().parent();
      
      // Set the radio button value
      $allLinks
        .parent()
        .find('input:radio[id=grade-' + $star.context.id + ']')
        .attr('checked', true);
        
      // Set the grades
      $allLinks.children().children().removeClass('grade');
      $star.addClass('grade');
      
      // prevent default link click
      e.preventDefault();
          
    }).hover(function() {
      // Handle star mouse over
      $(this).addClass('grade-over');
    }, function() {
      // Handle star mouse out
      $(this).siblings().andSelf().removeClass('grade-over');
    });    
  } 
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

function translate_validation_messages(locale) {
  jQuery.getJSON('/javascripts/locales/' + locale + '.json', function(json) {
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
        min: jQuery.validator.format(json.validation_messages.min)
    });
  });
}
