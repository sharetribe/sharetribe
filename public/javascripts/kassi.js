// Custom Javascript functions for Kassi

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

function initialize_new_listing_form(fileDefaultText, fileBtnText, locale) {
	$('#help_tags_link').click(function() { $('#help_tags').lightbox_me({centered: true}); });
	$('input.text_field:first').focus();
	$("select.listing_date_select, input:checkbox, input:file").uniform({
		selectClass: 'selector2', 
		fileDefaultText: fileDefaultText, 
		fileBtnText: fileBtnText
	});
	$("#new_listing").validate({
		debug: false,
		rules: {
			"listing[title]": {required: true, minlength: 2}
		}
	});
	translate_validation_messages(locale);
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
		accept: "Tiedosto on vääräntyyppinen.",
		maxlength: $.validator.format("Voit syöttää tähän kenttään maksimissaan {0} merkkiä."),
		minlength: $.validator.format("Syötä tähän kenttään vähintään {0} merkkiä."),
		rangelength: $.validator.format("Merkkimäärän tulee olla välillä {0} ja {1}."),
		range: $.validator.format("Kentän arvon tulee olla välillä {0} ja {1}."),
		max: $.validator.format("Arvo voi olla enintään {0}."),
		min: $.validator.format("Arvon täytyy olla vähintään {0}.")
	});
}

function set_textarea_maxlength() {
 
  // ignore these keys
  var ignore = [8,9,13,33,34,35,36,37,38,39,40,46];
 
  // use keypress instead of keydown as that's the only
  // place keystrokes could be canceled in Opera
  var eventName = 'keypress';
 
  // handle textareas with maxlength attribute
  $('textarea[maxlength]')
 
    // this is where the magic happens
    .live(eventName, function(event) {
      var self = $(this),
          maxlength = self.attr('maxlength'),
          code = $.data(this, 'keycode');
 
      // check if maxlength has a value.
      // The value must be greater than 0
      if (maxlength && maxlength > 0) {
 
        // continue with this keystroke if maxlength
        // not reached or one of the ignored keys were pressed.
        return ( self.val().length < maxlength
                 || $.inArray(code, ignore) !== -1 );
 
      }
    })
 
    // store keyCode from keydown event for later use
    .live('keydown', function(event) {
      $.data(this, 'keycode', event.keyCode || event.which);
    });
 
}