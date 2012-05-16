function initialize_defaults() {
  $('select.language_select').selectmenu({style: 'dropdown', width: "100px"});
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

function open_url(url) {
  window.location = url;
  return false;
}