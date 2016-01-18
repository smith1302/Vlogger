

var Videos = Parse.Object.extend("Videos");
var Follows = Parse.Object.extend("Follows");
var Likes = Parse.Object.extend("Likes");
var Flags = Parse.Object.extend("Flags");
var VideoUpdates = Parse.Object.extend("VideoUpdates");
var Story = Parse.Object.extend("Story");

// Only like video once
Parse.Cloud.beforeSave("Likes", function(request, response) {
	var query = new Parse.Query(Likes);
	query.equalTo("user", request.object.get("user"));
	query.equalTo("video", request.object.get("video"));
	query.first({
	  success: function(object) {
	    if (object) {
	      response.error("User already liked this video");
	    } else {
	      response.success();
	    }
	  },
	  error: function(error) {
	    response.error("Could not validate uniqueness for this Videos object.");
	  }
	});
});

// Only flag video once
Parse.Cloud.beforeSave("Flags", function(request, response) {
	var query = new Parse.Query(Likes);
	query.equalTo("user", request.object.get("user"));
	query.equalTo("video", request.object.get("video"));
	query.first({
	  success: function(object) {
	    if (object) {
	      response.error("User already flagged this video");
	    } else {
	      response.success();
	    }
	  },
	  error: function(error) {
	    response.error("Could not validate uniqueness for this flag object.");
	  }
	});
});

// Only follow user once
Parse.Cloud.beforeSave("Follows", function(request, response) {
  if (!request.object.get("toUser") || !request.object.get("fromUser")) {
    response.error('Follows must have a toUser and fromUser');
  } else {
    var query = new Parse.Query(Follows);
    query.equalTo("toUser", request.object.get("toUser"));
    query.equalTo("fromUser", request.object.get("fromUser"));
    query.first({
      success: function(object) {
        if (object) {
          response.error("Already following this user");
        } else {
          response.success();
        }
      },
      error: function(error) {
        response.error("Could not validate uniqueness for this Follows object.");
      }
    });
  }
});

Parse.Cloud.define("totalViews", function(request, response) {
  var query = new Parse.Query("Videos");
  var user = new Parse.Object.extend("_User");
  user.id = request.params.userID;

  query.equalTo("user", user);
  query.find({
    success: function(results) {
      var sum = 0;
      for (var i = 0; i < results.length; ++i) {
        sum += results[i].get("views");
      }
      response.success(sum);
    },
    error: function() {
      response.error("Total views lookup failed");
    }
  });
});

/* 
	Query for all videos in the last 24 hours
	getVideos.orderAscending.dateLessThan24hours.(videos) {
	if videos.count < 5 {
		let videosNeeded = 5 - videos.count
		getVideos.orderAscending.dateOlderThan24Hours.limit(videosNeeded).get(restVideos) {
			let totalVideos = videos.append(restVideos)
			return totalVideos
		}
	}
}
*/

Parse.Cloud.define("getFeedVideos", function(request, response) {
  var query = new Parse.Query("Videos");
  var user = new Parse.Object.extend("_User");
  user.id = request.params.userID;

  query.equalTo("user", user);
  query.greaterThanOrEqualTo("createdAt", request.params.oneDayAgo);
  query.ascending("createdAt")
  query.find({
    success: function(recentVideos) {
      var resultsLength = recentVideos.length;
      var videosNeeded = 2 - resultsLength;
      if (videosNeeded > 0) {
      	var query = new Parse.Query("Videos");
		query.equalTo("user", user);
		query.lessThan("createdAt", request.params.oneDayAgo);
		query.descending("createdAt")
		query.limit(videosNeeded);
		query.find({
    		success: function(olderVideos) {
    			response.success(olderVideos.reverse().concat(recentVideos));
    		},
    		error: function() {
		      response.error("Get old feed videos failed");
		    }
		});
      } else {
      	response.success(recentVideos);
      }
    },
    error: function() {
      response.error("Get recent feed videos failed");
    }
  });
});


// Update the likes/view on a story
Parse.Cloud.beforeSave("Videos", function(request, response) {
	var query = new Parse.Query(Story);
	query.equalTo("day", request.object.get("day"));
	query.first({
	  success: function(object) {
	    if (object) { // Object exists. Update it.
	    	if (request.object.dirty("likes")) {
	    		object.increment("likes", 1);
	    	}
	    	if (request.object.dirty("views")) {
	    		object.increment("views", 1);
	    	}
	    	object.save();
	    }
	    response.success();
	  },
	  error: function(error) {
	  	response.error("Videos before save error: "+error.message);
	  }
	});
});

// Create updates for video adds
Parse.Cloud.afterSave("Videos", function(request) {
	var query = new Parse.Query(VideoUpdates);
	query.equalTo("user", request.object.get("user"));
	query.first({
	  success: function(object) {
	    if (object) { // Object exists. Update it.
	    	object.set("video", request.object);
	    	object.save();
	    } else { // object doesnt exist, create it
	    	var videoUpdates = new VideoUpdates();
			videoUpdates.set("video", request.object);
			videoUpdates.set("user", request.object.get("user"));
			videoUpdates.save();
		}
	  },
	  error: function(error) {
	  	console.error("Got an error " + error.code + " : " + error.message);
	  }
	});

	var query = new Parse.Query(Story);
	// Check if we have that days story already
	query.equalTo("day", request.object.get("day"));
	query.first({
	  success: function(object) {
	    if (object) { // Object exists. Update it.
	    	// If its a new video object add it to the relation
	    	if (!request.object.existed()) {
		    	var relation = object.relation("videos");
				relation.add(request.object);
			}
	    	object.save();
	    } else { // object doesnt exist, create it
	    	if (!request.object.existed()) {
		    	var story = new Story();
		    	story.set("day", request.object.get("day"));
				story.set("user", request.object.get("user"));
				story.increment("likes", request.object.get("likes"));
		    	story.increment("views", request.object.get("views"));
				var relation = story.relation("videos");
				relation.add(request.object);
				story.save();
			}
		}
	  },
	  error: function(error) {
	  	console.error("Got an error " + error.code + " : " + error.message);
	  }
	});
});

Parse.Cloud.beforeDelete("Story", function(request, response) {
  var relation = request.object.relation("videos");
  var query = relation.query();
  query.find({
    success: function(posts) {
        Parse.Object.destroyAll(posts).then(function() {
            response.success();
        }, function(error) {
			response.error("Oops! Something went wrong: " + error.message + " (" + error.code + ")");
		});
    },
    error: function(error) {
        response.error("Error finding videos in story " + error.code + ": " + error.message);
    }
  });
});