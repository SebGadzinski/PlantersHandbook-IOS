//
//  Season.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

///Season.swift - Represents a planting season
class Season: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var title: String = "Season"
    @objc dynamic var date: Date = Date()
    var entries = List<String>()
    
    ///Gives primaryKey for class
    ///- Returns: id of user
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    ///Contructor that initalizes required fields
    ///- Parameter partition: Partition key used to identify what configuration the object belongs to
    ///- Parameter title: Name of season
    convenience init(partition: String, title: String) {
        self.init()
        self._partition = partition
        self.title = title
    }
    
}
