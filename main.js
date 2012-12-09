function check_blood_pressure_values() {
	// Check the values.
	var bp_top = $('#bp-top').val()
	var bp_bottom = $('#bp-bottom').val()

	if (bp_top > 140 || bp_bottom > 90) {
		$("<p>Your blood pressure is <span class='bp-bad'>TOO HIGH</span>.<br />" +
			"<input type='button' value='Help!' id='infobox' onclick=\"$(\'#info-box\').dialog(\'open\');initialize();\"></input></p>")
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

//function geolocate_gps() {
	var map;
	var service;
	var infowindow;
	
function initialize() {
	/*var positions = navigator.geolocation.getCurrentPosition();
	var latitude = positions.coords.latitude;
	var longitude = positions.coords.longitude;*/
	var current_location = new google.maps.LatLng(51.311623,-0.727762);
	var mapOptions = {
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		center: current_location,
		zoom: 15
	}
	var map = new google.maps.Map(document.getElementById('map_container', mapOptions));
	var gp_request = {
		location: current_location,
		radius: '500',
		query: 'gp',
		sensor: false
	}
	service = new google.maps.places.PlacesService(map);
	service.textSearch(gp_request, callback);
}

function callback(results, status) {
	if (status == google.maps.places.PlacesServiceStatus.OK) {
		for (var i = 0; i < results.length; i++) {
			if (i == 2) {
				break
			}
			var place = results[i];
			var place_name = place.name;
			var place_formatted_address = place.formatted_address;
			$("#map_container").append($("<h2>").text(place_name)).append($("<p>").text(place_formatted_address))
		}
	}
}
//}