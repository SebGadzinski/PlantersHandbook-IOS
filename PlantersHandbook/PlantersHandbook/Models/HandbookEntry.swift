//
//  HandbookEntry.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

class HandbookEntry: Object{
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var seasonId : String = UUID().uuidString
    @objc dynamic var date : Date = Date()
    var blocks = List<String>()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(partition: String, seasonId: String) {
        self.init()
        self._partition = partition
        self.seasonId = seasonId
    }
}