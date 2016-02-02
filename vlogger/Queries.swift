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
}