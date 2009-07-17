/*<![CDATA[*/
var good_thru_cal;      
window.onload = function () {
	good_thru_cal = new Epoch('epoch_popup','popup',document.getElementById('listing_good_thru'));
	good_thru_cal = new Epoch('epoch_popup','popup',document.getElementById('conversation_pick_up_time'));
	good_thru_cal = new Epoch('epoch_popup','popup',document.getElementById('conversation_return_time'));
};
/*]]>*/

function getDatetimeFromDatetimeSelect(model, attribute) {
	var day = $(model + '_' + attribute + '_3i').value;
	var month = $(model + '_' + attribute + '_2i').value;
	var year = $(model + '_' + attribute + '_1i').value;
	var hour = $(model + '_' + attribute + '_4i').value;
	var minute = $(model + '_' + attribute + '_5i').value;
	var date = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':00' 
	return date;
}

function getItemAmountsFromTextfields(item_ids) {
	var amounts = "";
	for (i = 0; i < item_ids.length; i++) {
		var amount = $('conversation_reserved_items_' + item_ids[i]).value;
		amounts += "amounts[]=" + amount;
		if (i < (item_ids.length - 1)) {
			amounts += "&";
		}
	}
	return amounts;
}