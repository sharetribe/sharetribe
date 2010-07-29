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
	$('#share_type_link').click(function() { $('#share_type').lightbox_me({centered: true}); });
	$('input.text_field:first').focus();
	$("select.listing_date_select, input:checkbox, input:file").uniform({
		selectClass: 'selector2',
		fileDefaultText: fileDefaultText, 
		fileBtnText: fileBtnText
	});
	var checkbox_message = "" 
	if (locale == "fi") {
		checkbox_message = 'Sinun pitää valita ainakin yksi ylläolevista.'
	} else {
		checkbox_message = 'You must check at least one of the boxes above.';
	}
	translate_validation_messages(locale);
	$("#new_listing").validate({
		errorPlacement: function(error, element) {
			if (element.attr("name") == "listing[share_type][]") {
				error.appendTo(element.parent().parent().parent().parent().parent().parent());
			} else {
				error.insertAfter(element);
			}
		},
		debug: false,
		rules: {
			"listing[title]": {required: true, minlength: 2},
			"listing[share_type][]": {required: true, minlength: 1}
		},
		messages: {
			"listing[share_type][]": {
				required: checkbox_message
			}
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

// Displays the right form for new listing based on the
// given listing category
function switch_category(category) {
	var selected = "listing_type_select_icon_selected_";
	var unselected = "listing_type_select_icon_unselected_";
	$('#listing_category').val(category);
	$('.one_checkbox_container:not(.' + category + ')').addClass('hidden');
	$('.one_checkbox_container.' + category).removeClass('hidden');
	$('.new_listing_form_field_container:not(.' + category + ')').addClass('hidden');
	$('.one_checkbox_container:not(.' + category + ') :input[type=checkbox]').attr('disabled', true);
	console.log('Disabled1:');
	$(':disabled').each(function(n){
	    id = n.id ? "ID: "+n.id : ""
	    console.log("%d: %s.%s %s",n,n.tagName,n.className,id)
	});
	$('.new_listing_form_field_container.' + category).removeClass('hidden');
	$('div.' + unselected + category).addClass(selected + category).removeClass(unselected + category);
	for (var i=0; i<categories().length; i++) {
		if (categories()[i] != category) {
			$('div.' + selected + categories()[i]).removeClass(selected + categories()[i]).addClass(unselected + categories()[i]);
		}
	}
	$('input.text_field:first').focus();
}

// Return listing categories
function categories() {
	return ["item", "favor", "rideshare", "housing"];
}