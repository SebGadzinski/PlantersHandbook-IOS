//
//  Cache.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import RealmSwift

///Cache.swift - Represents a cache on a working site
class Cache: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var _partition: String = ""
    @objc dynamic var subBlockId : String = UUID().uuidString
    @objc dynamic var title: String = "Cache"
    @objc dynamic var isPlanting: Bool = false
    @objc dynamic var treePerPlot: Int = 0
    var secondsPlanted = List<Int>()
    var treeTypes = List<String>()
    var centPerTreeTypes = List<Double>()
    var bundlesPerTreeTypes = List<Int>()
    var totalCashPerTreeTypes = List<Double>()
    var totalTreesPerTreeTypes = List<Int>()
    var bagUpsPerTreeTypes = List<BagUpInput>()
    var plots = List<PlotInput>()
    var coordinatesCovered = List<CoordinateInput>()
    
    ///Gives primaryKey for class
    ///- Returns: id of user
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    ///Contructor that initalizes required fields
    ///- Parameter partition: Partition key used to identify what configuration the object belongs to
    ///- Parameter title: Name of subBlocks
    ///- Parameter subBlockId: Id of subBlock that this Cache belongs to
    convenience init(partition: String, title: String, subBlockId: String) {
        self.init()
        self._partition = partition
        self.subBlockId = subBlockId
        self.title = title
        realmDatabase.clearCacheTally(cache: self){ success, error in
            if !success{
                print(error!)
            }
        }
    }
    
    //Testing Purposes
    convenience init(partition: String, title: String, subBlockId: String, treeTypes: List<String>, centPerTreeTypes: List<Double>, bundlesPerTreeTypes: List<Int>, bagUpsPerTreeTypes: List<BagUpInput>, plots: List<PlotInput>, totalCashPerTreeTypes: List<Double>, totalTreesPerTreeTypes: List<Int>, secondsPlanted: List<Int>, coordinatesCovered: List<CoordinateInput>) {
        self.init()
        self._partition = partition
        self.subBlockId = subBlockId
        self.title = title
        self.treeTypes = treeTypes
        self.centPerTreeTypes = centPerTreeTypes
        self.bundlesPerTreeTypes = bundlesPerTreeTypes
        self.bagUpsPerTreeTypes = bagUpsPerTreeTypes
        self.plots = plots
        self.totalCashPerTreeTypes = totalCashPerTreeTypes
        self.totalTreesPerTreeTypes = totalTreesPerTreeTypes
        self.secondsPlanted = secondsPlanted
        self.coordinatesCovered = coordinatesCovered
    }
    
}

//Realm Does not support double arrays, this is one solution

///BagUpInput - Bag up
class BagUpInput: EmbeddedObject{
    var input = List<Int>()
}

///PlotInput - Contains 2 plots (What a normal paper handbook has)
class PlotInput: EmbeddedObject{
    @objc dynamic var inputOne : Int = 0
    @objc dynamic var inputTwo : Int = 0
}

///CoordinateInput - Represents a path that user took
class CoordinateInput: EmbeddedObject{
    var input = List<Coordinate>()
}

///Coordinate - Coordinate
class Coordinate: EmbeddedObject{
    @objc dynamic var longitude : Double = 0.0
    @objc dynamic var latitude : Double = 0.0
    
    ///Contructor that initalizes required fields
    ///- Parameter longitude: Longitude of coordinate
    ///- Parameter latitude: Latitude of coordinate
    convenience init(longitude: Double, latitude: Double) {
        self.init()
        self.longitude = longitude
        self.latitude = latitude
    }
    
}
