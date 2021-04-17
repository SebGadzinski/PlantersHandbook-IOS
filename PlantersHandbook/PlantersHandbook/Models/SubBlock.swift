//
//  SubBlock.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

///SubBlock.swift - Represents a subBlock on a working site 
class SubBlock: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var blockId : String = UUID().uuidString
    @objc dynamic var title: String = "SubBlock"
    @objc dynamic var date: Date = Date()
    var caches = List<String>()
    
    ///Gives primaryKey for class
    ///- Returns: id of user
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    ///Contructor that initalizes required fields
    ///- Parameter partition: Partition key used to identify what configuration the object belongs to
    ///- Parameter title: Name of subBlocks
    ///- Parameter blockId: Id of block that this SubBlock belongs to
    convenience init(partition: String, title: String, blockId: String) {
        self.init()
        self._partition = partition
        self.blockId = blockId
        self.title = title
    }
    
}
