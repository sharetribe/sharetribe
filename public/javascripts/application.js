// A script for displaying the javascript calendar related to a text field.
// A calendar needs to be created separately in this function for each
// text field that makes use of the calendar.
/*<![CDATA[*/
var good_thru_cal;      
window.onload = function () {
	good_thru_cal = new Epoch('epoch_popup','popup',document.getElementById('listing_good_thru'));
};
/*]]>*/

// Returns a string that represents a value of a datetime_select
// for the given attribute in a form that is related to the given model 
function getDatetimeFromDatetimeSelect(model, attribute, gmt_offset) {
	day = $(model + '_' + attribute + '_3i').value;
	month = $(model + '_' + attribute + '_2i').value;
	year = $(model + '_' + attribute + '_1i').value;
	hour = $(model + '_' + attribute + '_4i').value;
	minute = $(model + '_' + attribute + '_5i').value;
	date = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':00 ' + gmt_offset
	return date;
}

// Returns amounts of given items from corresponding text fields
// in a reservation form. Amounts are required as a string that
// can be passed as an onchange event's "with" parameter
function getItemAmountsFromTextfields(item_ids) {
	amounts = "";
	for (i = 0; i < item_ids.length; i++) {
		amount = $('conversation_reserved_items_' + item_ids[i]).value;
		amounts += "amounts[]=" + amount;
		if (i < (item_ids.length - 1)) {
			amounts += "&";
		}
	}
	return amounts;
}

// Disables the "borrow selected" button if none of the
// item checkboxes in the profile is checked.
// Called in the onchange of each checkbox.
function disableBorrowSelectedButton () {
	selected = false;
	for (var i=0; i < document.select_borrowed_items_form.items_.length; i++) {
		if (document.select_borrowed_items_form.items_[i].checked) {
			selected = true;
		}
	}
	if (selected) {
		$("borrow_selected_button").disabled = false;
	} else {
		$("borrow_selected_button").disabled = true;
	}
}
