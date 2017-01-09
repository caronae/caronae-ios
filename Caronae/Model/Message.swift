//
//  Message.swift
//  Caronae
//
//  Created by Mario Cecchi on 03/01/2017.
//  Copyright © 2017 Mario Cecchi. All rights reserved.
//

import ObjectMapper
import RealmSwift

class Message: Object, Mappable {
    dynamic var id: Int = 0
    dynamic var date: Date!
    dynamic var body: String!
    dynamic var sender: User!
    dynamic var ride: Ride!
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        date <- (map["date"], DateTimeTransform())
        body <- map["body"]
        sender <- map["user"]
    }
    
    var incoming: Bool {
        return sender != UserService.instance.user
    }
}

