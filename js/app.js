(function($, body, geo, Parse, Firebase){

	"use strict";

	var api, user, location, selectedVenue;
	var loader = $("#loader");
	var venueResults = $('#venue-results').on('click', '.venue-result', toggleVenue);
	var notification = $('#notification').click(hideNotification).on('click', '.loc', requireLocation);
	var venueQuery = $('#venue-search-field').on('keyup', debounced(findVenues, 700));
	var venueSearch = { lastValue: null, lastTransport: null };
	var captionField = $('#caption-field').keydown(checkCaptionSubmission);
	var captionStatus = $("#status");
	$('.connect-btn').on('click', authenticate);
	$('#venue-form').submit(findVenues);
	$('#caption-form').submit(checkCaptionSubmission);

	var PubSubUser, PubSubVenue, PubSub = new Firebase('https://blazing-fire-9021.firebaseio.com');
	Parse.initialize("Y3hSYuF2y9tzwgyaBGtu0IKSSLgNPyFX8QRaUo00", "RtAhaq1EZavaifdetmMePZwIGZ37tGMrCWwtKbdl");
	$.Marelle('EP5PE0WLZIMC4NUMM1IY2J00BE43XULPCEFEU11MDHJ15MP3').then(init, showApiError);

	function init(M) {
		api = M;
		toggleLoader(true);
		var def = api.authenticateVisitor();
		def.done(whenAuthenticated);
		def.fail(whenUnauthenticated);
		def.always(whenReady);
	}

	function debounced(fn, delay) {
		var timeout;
		return function(event) {
			if (timeout) clearTimeout(timeout);
			timeout = setTimeout(function(){
				timeout = null;
				fn(event);
			}, delay);
		};
	}

	function authenticate() {
		api.startSession();
	}

	function toggleVenue(event) {

		var target   = $(event.currentTarget);
		var selected = body.hasClass('selected');
		var method   = selected ? 'check_out' : 'check_in';
		var venue    = selected ? null : target.data();
		var job      = $.Deferred();
		var params   = { user: user, venue: venue };
		var handlers = { success: job.resolve, error: job.reject };

		toggleLoader(true);

		Parse.Cloud.run(method, params, handlers);

		job.then(function(vbuser, vbvenue){

			PubSubUser = PubSub.child("users").child(user.id);
			PubSubUser.remove();

			if (selectedVenue = venue) {
				PubSubVenue = PubSub.child("venues").child(venue.id).child(user.id);
			} else if(!PubSubVenue) {
				PubSubVenue = PubSub.child("venues").child(vbvenue.get('foursquareID')).child(user.id);
			}
			if (selectedVenue) {
				PubSubVenue.set(vbuser.id);
			} else {
				PubSubVenue.remove();
				PubSubVenue = null;
			}
			target.siblings().toggleClass('visible');
			body.toggleClass('selected');
		}, function(){
			showNotification('error', 'Unable to ' + method.replace('_', ' ') + ', please try again.');
		});

		job.always(function(){
			toggleLoader(false);
		});

	}

	function checkCaptionSubmission(event) {
		if (event.type === 'keydown') {
			if (!(event.metaKey && event.which === 13))
				return;
		}
		var value = $.trim(captionField.val());
		if (!user || !selectedVenue || !value) {
			updateStatus('Caption value required!');
			return;
		}
		submitCaption(value);
	}

	function updateStatus(html) {
		captionStatus.html(html);
	}

	function submitCaption(caption) {
		updateStatus('Submitting caption...');
		captionField.val('');
		PubSubUser.push(caption, function(error){
			if (error) showCaptionError();
			else updateStatus('Caption sent!');
			captionField.prop('disabled', false);
		});
	}

	function showCaptionError() {
		showNotification('error', 'Unable to communicate with our servers, please try again later');
		updateStatus('An error occurred.');
	}

	function requireLocation() {
		var when = $.Deferred();
		if (!geo) when.reject({ code: -1 });
		else geo.getCurrentPosition(when.resolve, when.reject);
		when.then(whenLocated, whenUnlocated);
		when.always(whenDoneLocating);
		return when.promise();
	}

	function findVenues(event) {
		if (event.type === 'submit')
			event.preventDefault();
		var coords = location.coords;
		var value = venueQuery.val();
		if (venueSearch.lastValue == value) {
			return;
		} else {
			venueSearch.lastValue = value;
		}
		if (venueSearch.lastTransport) {
			venueSearch.lastTransport.abort()
		}
		toggleLoader(true);
		venueResults.empty();
		venueSearch.lastTransport = api.Venue.search({
			ll:     coords.latitude + ',' + coords.longitude,
			llAcc:  coords.accuracy,
			query:  value,
			limit:  10,
			intent: 'browse',
			radius: 5000
		});
		venueSearch.lastTransport.then(renderVenueSearch, showApiError);
		venueSearch.lastTransport.always(endVenueSearch);
	}

	function renderVenueSearch(search) {
		var venues = search.response.venues;
		if (venues.length > 0) {
			$.each(venues, renderVenueResult);
		} else {
			renderNoVenueResults();
		}
	}

	function replacer(obj) {
		return function(m, key){
			if (!obj) {
				return '';
			} if (key.indexOf('.') > -1) {
				key = key.split('.');
				return replacer(obj[key[0]]).call(null, m, key.slice(1).join('.'));
			} else if (key in obj) {
				return obj[key];
			} else {
				return '';
			}
		}
	}

	function renderVenueResult(i, venue) {
		var template = '<li class="venue-result"><strong>{{name}}</strong><span>{{location.address}}</span></li>';
		var html = template.replace(/\{\{(.+?)\}\}/g, replacer(venue));
		var node = $(html).data(venue);
		venueResults.append(node);
		setTimeout(function(){ node.addClass('visible') }, 50);
	}

	function renderNoVenueResults() {
		venueResults.html('<li class="no-result">No Venues Found!</li>');
	}

	function showApiError() {
		showNotification('error', 'Unable to communicate with foursquare, please try again later');
	}

	function showLocationError(error) {
		var message;
		switch(error.code) {
			case error.TIMEOUT:
			case error.POSITION_UNAVAILABLE:
				message = 'Location information is unavailable. Please <a class="loc">try again</a> later';
				break;
			default:
				message = 'Location services are required to search for venues, please enable it and <a class="loc">try again</a>';
				break;
		}
		showNotification('error', message);
	}

	function toggleLoader(show) {
		loader.toggleClass('active', show);
	}

	function endVenueSearch() {
		toggleLoader(false);
		venueSearch.lastTransport = null;
	}

	function showNotification(klass, html) {
		notification.removeClass('error warning success').addClass(klass+' open').html(html);
	}

	function hideNotification() {
		notification.removeClass('open');
	}

	function whenAuthenticated(auth) {
		user = auth.response.user;
		body.addClass('authenticated');
		requireLocation();
	}

	function whenUnauthenticated() {
		toggleLoader(false);
		body.removeClass('authenticated');
	}

	function whenLocated(loc) {
		location = loc;
		body.addClass('located');
	}

	function whenUnlocated(error) {
		body.removeClass('located');
		showLocationError(error);
	}

	function whenDoneLocating() {
		toggleLoader(false);
	}

	function whenReady() {
		body.addClass('ready');
	}

})(jQuery, jQuery(document.body), navigator.geolocation, Parse, Firebase);
