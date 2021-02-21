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
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(partition: String, title: String, subBlockId: String) {
        self.init()
        self._partition = partition
        self.subBlockId = subBlockId
        self.title = title
        realmDatabase.emptyTallyPrimitiveList(list: self.treeTypes, appending: "" ){ success, error in
            if success{
                realmDatabase.emptyTallyPrimitiveList(list: self.centPerTreeTypes, appending: 0.0){ success, error in
                    if success{
                        realmDatabase.emptyTallyPrimitiveList(list: self.bundlesPerTreeTypes, appending: 0){ success, error in
                            if success{
                                realmDatabase.emptyTallyPrimitiveList(list: self.totalCashPerTreeTypes, appending: 0.0){ success, error in
                                    if success{
                                        realmDatabase.emptyTallyPrimitiveList(list: self.totalTreesPerTreeTypes, appending: 0){ success, error in
                                            if success{
                                                realmDatabase.emptyTallyBagUps(list: self.bagUpsPerTreeTypes){ success, error in
                                                    if success{
                                                        realmDatabase.emptyTallyPlots(list: self.plots){ success, error in
                                                            if success{
                                                                realmDatabase.emptyCacheCoordinates(list: self.coordinatesCovered){ success, error in
                                                                    if success{
                                                                        print("Cache created")
                                                                    }else{print(error!)}
                                                                }
                                                            }else{print(error!)}
                                                        }
                                                    }else{print(error!)}
                                                }
                                            }else{print(error!)}
                                        }
                                    }else{print(error!)}
                                }
                            }else{print(error!)}
                        }
                    }else{print(error!)}
                }
            }else{print(error!)}
        }
    }
    
}

//Realm Does not support double arrays, this is one solution

class BagUpInput: EmbeddedObject{
    var input = List<Int>()
}

class PlotInput: EmbeddedObject{
    @objc dynamic var inputOne : Int = 0
    @objc dynamic var inputTwo : Int = 0
}

class CoordinateInput: EmbeddedObject{
    var input = List<Coordinate>()
}

class Coordinate: EmbeddedObject{
    @objc dynamic var longitude : Double = 0.0
    @objc dynamic var latitude : Double = 0.0
    
    convenience init(longitude: Double, latitude: Double) {
        self.init()
        self.longitude = longitude
        self.latitude = latitude
    }
}

