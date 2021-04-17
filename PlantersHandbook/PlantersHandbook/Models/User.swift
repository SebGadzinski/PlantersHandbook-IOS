//
//  User.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

///User.swift - Represents a User
class User: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var _partition: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var company: String = ""
    @objc dynamic var stepDistance: Int = 0
    var seasons = List<String>()
    
    ///Gives primaryKey for class
    ///- Returns: id of user
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    ///Contructor that initalizes required fields
    ///- Parameter id: Id of user
    ///- Parameter partition: Partition key used to identify what configuration the object belongs to
    ///- Parameter name: Name of user
    ///- Parameter company: Company user works for
    ///- Parameter seasons: Seasons user has
    ///- Parameter stepDistance: Step distance of user
    convenience init(_id: String, partition: String, name: String, company: String, seasons: List<String>, stepDistance: Int) {
        self.init()
        self._id = _id
        self._partition = partition
        self.name = name
        self.company = company
        self.seasons = seasons
        self.stepDistance = stepDistance
    }
    
}
