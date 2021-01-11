//
//  Block.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

class Block: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var entryId : String = UUID().uuidString
    @objc dynamic var title: String = "Block"
    @objc dynamic var date: Date = Date()
    var subBlocks = List<String>()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(partition: String, title: String, entryId: String) {
        self.init()
        self._partition = partition
        self.entryId = entryId
        self.title = title
    }
    
}
