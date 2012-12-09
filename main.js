function check_blood_pressure_values() {
	// Check the values.
	var bp_top = $('#bp-top').val()
	var bp_bottom = $('#bp-bottom').val()

	if (bp_top > 140 || bp_bottom > 90) {
		$("<p>Your blood pressure is <span class='bp-bad'>TOO HIGH</span>.<br />" +
			"<input type='button' value='Help!' id='infobox' onclick=\"$(\'#info-box\').dialog(\'open\');\"></input></p>")
			.appendTo($("#content"))
	} else if (bp_top > 120 || bp_bottom > 80) {
		$("<p>Your blood pressure is <span id='bp-moderate'>SLIGHTLY HIGH</span>.</p>")
			.appendTo("#content")
	} else if (bp_top > 90 || bp_bottom > 60) {
		$("<p>Your blood pressure is <span id='bp-good'>FINE</span>.</p>")
			.appendTo($("#content"))
	} else if (bp_top > 0 && bp_bottom > 0) {
		$("<p>Your blood pressure is <span class='bp-bad'>TOO LOW</span>.</p>")
			.appendTo($("#content"))
	} else {
		$("<p>You must be <span class='bp-bad'>DEAD</span>.</p>")
			.appendTo("#content")
	}
}

$(function () {
	// Dialog box for displaying the info if blood pressure is too high.
	$('#info-box').dialog({
		autoOpen: false, 
		width: 500,
		modal: true,
		resizable: false,
		draggable: false,
		buttons: {
			"Exit": function() {
				$(this).dialog("close");
			}
		}
	});
});