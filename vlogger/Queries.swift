//
//  Queries.swift
//  vlogger
//
//  Created by Eric Smith on 2/1/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import Foundation
import Parse

class Queries {
    class func popularQuery() -> PFQuery {
        let query = User.query()
        query?.orderByDescending("subscriberCount")
        query?.limit = 5
        return query!
    }
    
    class func userStoriesQuery(user:User, exclude initialStory:Story?) -> PFQuery {
        let storyQuery = Story.query()
        storyQuery?.whereKey("user", equalTo: user)
        excludeFromQuery(exclude: initialStory, query: storyQuery!)
        storyQuery?.orderByDescending("createdAt")
        storyQuery?.includeKey("user")
        return storyQuery!
    }
    
    class func trendingStoriesQuery(exclude initialStory:Story?) -> PFQuery {
        let storyQuery = Story.query()
        storyQuery?.whereKey("videoAddedAt", greaterThan: NSDate(timeIntervalSinceNow: -60*60*24*7))
        //storyQuery?.whereKey("active", equalTo: true)
        excludeFromQuery(exclude: initialStory, query: storyQuery!)
        storyQuery?.orderByDescending("featured")
        storyQuery?.whereKey("videoCount", greaterThanOrEqualTo: 1)
        storyQuery?.addDescendingOrder("views")
        storyQuery?.includeKey("user")
        return storyQuery!
    }
    
    private class func excludeFromQuery(exclude object:PFObject?, query:PFQuery) -> PFQuery {
        if let ID = object?.objectId {
            query.whereKey("objectId", notEqualTo: ID)
        }
        return query
    }
}