// Custom Javascript functions for Kassi

// Add custom validation methods
$.validator.
	addMethod( "accept", 
		function(value, element, param) {
			return value.match(new RegExp("(\.jpe?g|\.gif|\.png|^$)"));
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

// Initialize code that is needed for every view
function initialize_defaults(default_text) { 
	$('input.search_field').empty_value(default_text, true, 'default_text');
	$("select.language_select").uniform();
	$('#close_notification_link').click(function() { $('#notifications').slideUp('fast'); });
}

function initialize_login_form() {
	$('#password_forgotten_link').click(function() { $('#password_forgotten').slideToggle('slow'); });
  $('input.text_field:first').focus();
}

function initialize_new_listing_form(fileDefaultText, fileBtnText, locale, checkbox_message, date_message, is_rideshare, is_offer) {
	$('#help_tags_link').click(function() { $('#help_tags').lightbox_me({centered: true}); });
	$('#help_share_type_link').click(function() { $('#help_share_type').lightbox_me({centered: true}); });
	$('#help_valid_until_link').click(function() { $('#help_valid_until').lightbox_me({centered: true}); });
	$('input.text_field:first').focus();
	$("select.listing_date_select, input:checkbox, input:file, input:radio").uniform({
		selectClass: 'selector2',
		fileDefaultText: fileDefaultText, 
		fileBtnText: fileBtnText
	});
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
	translate_validation_messages(locale);
	$("#new_listing").validate({
		errorPlacement: function(error, element) {
			if (element.attr("name") == "listing[share_type][]") {
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
			"listing[title]": {required: true, minlength: 2},
			"listing[origin]": {required: true, minlength: 2},
			"listing[destination]": {required: true, minlength: 2},
			"listing[share_type][]": {required: true, minlength: 1},
			"listing[listing_images_attributes][0][image]": { accept: "(jpe?g|gif|png)" },
			"listing[valid_until(5i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(4i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(3i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(2i)]": { min_date: is_rideshare, max_date: is_rideshare },
			"listing[valid_until(1i)]": { min_date: is_rideshare, max_date: is_rideshare }
		},
		messages: {
			"listing[share_type][]": { required: checkbox_message },
			"listing[valid_until(1i)]": { min_date: date_message, max_date: date_message },
			"listing[valid_until(2i)]": { min_date: date_message, max_date: date_message  },
			"listing[valid_until(3i)]": { min_date: date_message, max_date: date_message  },
			"listing[valid_until(4i)]": { min_date: date_message, max_date: date_message  },
			"listing[valid_until(5i)]": { min_date: date_message, max_date: date_message  }
		}
	});
	set_textarea_maxlength();
}

function translate_validation_messages(locale) {
	if (locale == "fi") {
		translate_validation_messages_to_finnish();
	}
}

function translate_validation_messages_to_finnish() {
	jQuery.extend(jQuery.validator.messages, {
		required: "Tämä on pakollinen kenttä.",
		remote: "Tässä kentässä on virhe.",
		email: "Anna toimiva sähköpostiosoite.",
		url: "Anna oikeanlainen URL-osoite.",
		date: "Anna päivämäärä oikessa muodossa.",
		dateISO: "Anna päivämäärä oikeassa muodossa (ISO).",
		number: "Annetun arvon pitää olla numero.",
		digits: "Tähän kenttään voit syöttää ainoastaan kirjaimia.",
		creditcard: "Anna oikeantyyppinen luottokortin numero.",
		equalTo: "Antamasi arvot eivät täsmää.",
		accept: "Kuvatiedosto on vääräntyyppinen. Sallitut tiedostomuodot: JPG, PNG ja GIF.",
		maxlength: $.validator.format("Voit syöttää tähän kenttään maksimissaan {0} merkkiä."),
		minlength: $.validator.format("Syötä tähän kenttään vähintään {0} merkkiä."),
		rangelength: $.validator.format("Merkkimäärän tulee olla välillä {0} ja {1}."),
		range: $.validator.format("Kentän arvon tulee olla välillä {0} ja {1}."),
		max: $.validator.format("Arvo voi olla enintään {0}."),
		min: $.validator.format("Arvon täytyy olla vähintään {0}."),
		min_date: "Ilmoituksen viimeinen voimassaolopäivä ei voi olla aikaisempi kuin nykyhetki."
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