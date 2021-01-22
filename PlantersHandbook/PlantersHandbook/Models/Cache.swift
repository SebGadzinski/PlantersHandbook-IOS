//
//  Cache.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

class Cache: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var subBlockId : String = UUID().uuidString
    @objc dynamic var title: String = "Cache"
    var treeTypes = List<String>()
    var centPerTreeTypes = List<Double>()
    var bundlesPerTreeTypes = List<Int>()
    var totalCashPerTreeTypes = List<Double>()
    var totalTreesPerTreeTypes = List<Int>()
    var bagUpsPerTreeTypes = RealmSwift.List<BagUpInput>()
    var plots = RealmSwift.List<PlotInput>()
    var coordinatesCovered = RealmSwift.List<Coordinate>()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(partition: String, title: String, subBlockId: String) {
        self.init()
        self._partition = partition
        self.subBlockId = subBlockId
        self.title = title
        emptyTallyStringList(list: self.treeTypes)
        emptyTallyDoubleList(list: self.centPerTreeTypes)
        emptyTallyIntList(list: self.bundlesPerTreeTypes)
        emptyTallyDoubleList(list: self.totalCashPerTreeTypes)
        emptyTallyIntList(list: self.totalTreesPerTreeTypes)
        emptyTallyBagUps(list: self.bagUpsPerTreeTypes)
        emptyTallyPlots(list: self.plots)
    }
    
}

//Realm Does not support double arrays, this is one solution

class BagUpInput: EmbeddedObject{
    var input = List<Int>()
}

class PlotInput: EmbeddedObject{
    var inputOne = List<Int>()
    var inputTwo = List<Int>()
}

class Coordinate: EmbeddedObject{
    @objc var longitude : Double = 0.0
    @objc var latitude : Double = 0.0
}

