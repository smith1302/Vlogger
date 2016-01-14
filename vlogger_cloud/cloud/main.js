
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var Follows = Parse.Object.extend("Follows");
var Likes = Parse.Object.extend("Likes");
var Flags = Parse.Object.extend("Flags");

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
  query.find({
    success: function(recentVideos) {
      var resultsLength = recentVideos.length;
      var videosNeeded = 5 - resultsLength;
      if (videosNeeded > 0) {
      	var query = new Parse.Query("Videos");
		query.equalTo("user", user);
		query.lessThan("createdAt", request.params.oneDayAgo);
		query.limit(videosNeeded);
		query.find({
    		success: function(olderVideos) {
    			response.success(olderVideos.concat(recentVideos));
    		},
    		error: function() {
		      response.error("Get old feed videos failed");
		    }
		});
      }
    },
    error: function() {
      response.error("Get recent feed videos failed");
    }
  });
});