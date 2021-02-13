//
//  User.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var _partition: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var company: String = ""
    var seasons = List<String>()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(_id: String, partition: String, name: String, company: String, seasons: List<String>) {
        self.init()
        self._id = _id
        self._partition = partition
        self.name = name
        self.company = name
        self.seasons = seasons
    }
    
}
