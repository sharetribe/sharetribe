function initialize_confirmation_pending_form(locale, email_in_use_message) {
	$('#mistyped_email_link').click(function() { 
		$('#password_forgotten').slideToggle('fast'); 
		$('input.email').focus();
	});
	var form_id = "#change_mistyped_email_form"
  $(form_id).validate({
     errorPlacement: function(error, element) {
       error.insertAfter(element);
     },
     rules: {
       "person[email]": {required: true, email: true, remote: "/people/check_email_availability_and_validity"}
     },
     messages: {
       "person[email]": { remote: email_in_use_message }
     },
     onkeyup: false, //Only do validations when form focus changes to avoid exessive ASI calls
     submitHandler: function(form) {
       disable_and_submit(form_id, form, "false", locale);  
     }
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

function disable_submit_button(form_id, locale) {
  $(form_id + ' input[type=submit]').attr('disabled', 'disabled');
	jQuery.getJSON('/javascripts/locales/' + locale + '.json', function(json) {
	  $(form_id + ' input[type=submit]').val(json.please_wait);
	});
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