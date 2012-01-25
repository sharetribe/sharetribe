function initialize_dashboard(email_default_text) { 
	$('#contact_request_email').watermark(email_default_text, {className: 'default_text'});
	$('select.language_select').selectmenu({style: 'dropdown', width: "100px"});
}

function initialize_campaign_page(select_default) {
	$('select.language_select').selectmenu({style: 'dropdown', width: "100px"});
	$('select.community_select').selectmenu({width: "370px", maxHeight: 175, style: 'dropdown'});
	//Remove unnecessary default "select neighborhood" option from the menu
	$('a:contains("' + select_default + '")').eq(1).parent().remove();
}

function open_url(url) {
  window.location = url;
  return false;
}