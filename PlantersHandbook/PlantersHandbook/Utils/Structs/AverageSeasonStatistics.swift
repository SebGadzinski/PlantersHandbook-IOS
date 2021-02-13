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
    var averageTimeSecondsPlanting : Int
    
    
    init(averageCash: Double, averageTrees: Int, averageDistanceTravelled: Double, averageTimeSecondsPlanting: Int){
        self.averageCash = averageCash
        self.averageTrees = averageTrees
        self.averageDistanceTravelled = averageDistanceTravelled
        self.averageTimeSecondsPlanting = averageTimeSecondsPlanting
    }
    
    init() {
        self.averageCash = 0
        self.averageTrees = 0
        self.averageDistanceTravelled = 0
        self.averageTimeSecondsPlanting = 0
    }
    
}
