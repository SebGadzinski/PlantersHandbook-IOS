//
//  SubBlock.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

class SubBlock: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var blockId : String = UUID().uuidString
    @objc dynamic var title: String = "SubBlock"
    @objc dynamic var date: Date = Date()
    var caches = List<String>()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
