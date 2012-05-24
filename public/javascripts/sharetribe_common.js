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