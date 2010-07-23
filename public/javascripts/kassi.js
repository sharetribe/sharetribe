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

function initialize_new_listing_form(fileDefaultText, fileBtnText) {
	$('#help_tags_link').click(function() { $('#help_tags').lightbox_me({centered: true}); });
	$('input.text_field:first').focus();
	$("select.listing_date_select, input:checkbox, input:file").uniform({
		selectClass: 'selector2', 
		fileDefaultText: fileDefaultText, 
		fileBtnText: fileBtnText
	});
}

// $(document).ready(function () {
// 		$("#new_listing").validate({
// 			debug: true,
// 			rules: {
// 				"listing[title]": {required: true, minlength: 2}
// 			}
// 		});
// });