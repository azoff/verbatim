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

function publishUserCaption(user, caption) {
	return createObject("VBPubSub", {
		channel: "User"+user.get('foursquareID'),
		data: { caption: caption }
	});
}

Parse.Cloud.define('send_caption', function(request, response){
	var venue   = request.params.venue;
	var user    = request.params.user;
	var caption = request.params.caption;
	if (!user    || !user.id)        return response.error("Invalid user param");
	if (!venue   || !venue.id)       return response.error("Invalid venue param");
	if (!caption || !caption.length) return response.error("Invalid caption param");
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
			return publishUserCaption(user, caption).
				then(response.success, response.error);
		}, response.error)
	}, response.error);
});
