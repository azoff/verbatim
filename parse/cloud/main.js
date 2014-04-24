function findFoursquareObject(classname, foursquareID) {
	var query = new Parse.Query(Parse.Object.extend(classname));
	query.equalTo('foursquareID', foursquareID);
	return query.first();
}

function updateObject(obj, properties) {
	Object.keys(properties).forEach(function(key){
		obj.set(key, properties[key]);
	});
	return obj.save();
}

function createObject(classname, properties) {
	var Class_ = Parse.Object.extend(classname);
	var obj = new Class_();
	return updateObject(obj, properties);
}

function findOrCreateFoursquareObject(classname, properties) {
	return findFoursquareObject(classname, properties.foursquareID).then(function(obj){
		return obj ? updateObject(obj, properties) : createObject(classname, properties);
	});
}

Parse.Cloud.define('check_in', function(request, response){
	var venue   = request.params.venue;
	var user    = request.params.user;
	if (!user    || !user.id)        return response.error("Invalid user param");
	if (!venue   || !venue.id)       return response.error("Invalid venue param");
	findOrCreateFoursquareObject('VBVenue', {
		foursquareID: venue.id,
		name: venue.name,
		address: venue.location.address
	}).then(function(venue){
		findOrCreateFoursquareObject('VBUser', {
			foursquareID: user.id,
			name: user.name,
			firstName: user.firstName,
			lastName: user.lastName,
			canonical: true,
			venue: venue
		}).then(function(user){
			response.success(user, venue);
		}, response.error)
	}, response.error);
});

Parse.Cloud.define('check_out', function(request, response){
	var user    = request.params.user;
	if (!user    || !user.id)        return response.error("Invalid user param");
	findOrCreateFoursquareObject('VBUser', {
		foursquareID: user.id,
		name: user.name,
		firstName: user.firstName,
		lastName: user.lastName,
		canonical: false
	}).then(function(user){
		var venue = user.get('venue');
		if (venue) {
			user.set('venue', null);
			user.save();
		}
		response.success(user, venue);
	}, response.error)
});
