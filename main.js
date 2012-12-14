function check_blood_pressure_values() {
	// Check the values.
	var bp_top = $('#bp-top').val()
	var bp_bottom = $('#bp-bottom').val()

	if (bp_top > 140 || bp_bottom > 90) {
		$("#bp_result").html("<p>Your blood pressure is <span class='bp-bad'>TOO HIGH</span>.<br /><input type='button' value='Help!' id='infobox' onclick=\"$(\'#info-box\').dialog(\'open\');initialize();\"></input></p>");
	} else if (bp_top > 120 || bp_bottom > 80) {
		$("#bp_result").html("<p>Your blood pressure is <span id='bp-moderate'>SLIGHTLY HIGH</span>.<br /><input type='button' value='Help!' id='infobox' onclick=\"$(\'#info-box\').dialog(\'open\');initialize();\"></input></p>")
	} else if (bp_top > 90 || bp_bottom > 60) {
		$("#bp_result").html("<p>Your blood pressure is <span id='bp-good'>FINE</span>.</p>")
	} else if (bp_top > 0 && bp_bottom > 0) {
		$("#bp_result").html("<p>Your blood pressure is <span class='bp-bad'>TOO LOW</span>.<br /><input type='button' value='Help!' id='infobox' onclick=\"$(\'#info-box\').dialog(\'open\');initialize();\"></input></p>")
	} else {
		$("#bp_result").html("<p>You must be <span class='bp-bad'>DEAD</span>.</p>")
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

function initialize() {
		// Geolocation!
        var latitude = 51.4791;
        var longitude = 0.0;
        navigator.geolocation.getCurrentPosition(got_position,position_error,{'timeout':10000});
}

function got_position(position) {
        var latitude = position.coords.latitude;
        var longitude = position.coords.longitude;
        var current_location = new google.maps.LatLng(latitude,longitude);
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

function position_error(err) {
        alert("Geolocation error.");
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