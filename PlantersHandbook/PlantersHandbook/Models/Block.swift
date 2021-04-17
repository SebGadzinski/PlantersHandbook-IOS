//
//  Block.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

///Block.swift - Represents a block on a working site 
class Block: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var entryId : String = UUID().uuidString
    @objc dynamic var title: String = "Block"
    @objc dynamic var date: Date = Date()
    var subBlocks = List<String>()
    
    ///Gives primaryKey for class
    ///- Returns: id of user
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    ///Contructor that initalizes required fields
    ///- Parameter partition: Partition key used to identify what configuration the object belongs to
    ///- Parameter title: Name of block
    ///- Parameter entryId: Id of handbookEntry that this Block belongs to
    convenience init(partition: String, title: String, entryId: String) {
        self.init()
        self._partition = partition
        self.entryId = entryId
        self.title = title
    }
    
}
