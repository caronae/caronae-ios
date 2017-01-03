//
//  User.swift
//  Caronae
//
//  Created by Mario Cecchi on 03/01/2017.
//  Copyright © 2017 Mario Cecchi. All rights reserved.
//

import ObjectMapper
import RealmSwift

class User: Object, Mappable {
    dynamic var id: Int = 0
    dynamic var name: String!
    dynamic var profile: String!
    dynamic var course: String!
    dynamic var email: String!
    dynamic var phoneNumber: String!
    dynamic var location: String!
    dynamic var carOwner: Bool = false
    dynamic var carModel: String? = nil
    dynamic var carPlate: String?
    dynamic var carColor: String?
    dynamic var profilePictureURL: String?
    dynamic var facebookID: String!
    dynamic var createdAt: Date!
    dynamic var numRides: Int = 0
    dynamic var numDrives: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        profile <- map["profile"]
        course <- map["course"]
        email <- map["email"]
        phoneNumber <- map["phone_number"]
        location <- map["location"]
        carOwner <- map["car_owner"]
        carModel <- map["car_model"]
        carPlate <- map["car_plate"]
        carColor <- map["car_color"]
        profilePictureURL <- map["profile_pic_url"]
        facebookID <- map["face_id"]
        createdAt <- (map["created_at"], DateTimeTransform())
        numRides <- map["numRides"]
        numDrives <- map["numDrives"]
    }
    
    var firstName: String {
        return ""
    }
}
