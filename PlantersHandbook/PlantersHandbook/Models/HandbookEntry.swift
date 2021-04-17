//
//  HandbookEntry.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

///HandbookEntry.swift - Represents one handbook entry
class HandbookEntry: Object{
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var seasonId : String = UUID().uuidString
    @objc dynamic var notes: String = ""
    @objc dynamic var date : Date = Date()
    var blocks = List<String>()
    var extraCash = List<ExtraCash>()

    ///Gives primaryKey for class
    ///- Returns: id of user
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    ///Contructor that initalizes required fields
    ///- Parameter partition: Partition key used to identify what configuration the object belongs to
    ///- Parameter seasonId: Id of season that this HandbookEntry belongs to
    convenience init(partition: String, seasonId: String) {
        self.init()
        self._partition = partition
        self.seasonId = seasonId
    }
    
    ///Testing Purposes
    convenience init(partition: String, seasonId: String, date: Date) {
        self.init()
        self._partition = partition
        self.seasonId = seasonId
        self.date = date
    }

}

///ExtraCash - Represents extra cash made in a day
class ExtraCash: EmbeddedObject{
    @objc dynamic var reason = ""
    @objc dynamic var cash = Double()
}
