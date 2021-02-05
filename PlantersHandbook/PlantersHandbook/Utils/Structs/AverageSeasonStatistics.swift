//
//  AverageSeasonStatistics.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import Foundation

struct AverageSeasonStatistics{
    var averageCash : Double
    var averageTrees : Int
    var averageDistanceTravelled : Double
    
    
    init(averageCash: Double, averageTrees: Int, averageDistanceTravelled: Double){
        self.averageCash = averageCash
        self.averageTrees = averageTrees
        self.averageDistanceTravelled = averageDistanceTravelled
    }
    
    init() {
        self.averageCash = 0
        self.averageTrees = 0
        self.averageDistanceTravelled = 0
    }
    
}
