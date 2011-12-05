function initialize_dashboard(email_default_text) { 
	$('#contact_request_email').watermark(email_default_text, {className: 'default_text'});
	$('select.language_select').selectmenu({style: 'dropdown', width: "100px"});
}