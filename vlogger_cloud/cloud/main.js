
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var Follows = Parse.Object.extend("Follows");
var Likes = Parse.Object.extend("Likes");

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
  query.equalTo("userID", request.params.userID);
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