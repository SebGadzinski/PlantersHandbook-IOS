//
//  AverageSeasonStatistics.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import Foundation

///AverageSeasonStatistics.swift - All average statistics from a season
struct AverageSeasonStatistics{
    var averageCash : Double
    var averageTrees : Int
    var averageDistanceTravelled : Double
    var averageTimeSecondsPlanting : Int
    
    ///Parameterized contructor that initalizes all fields all fields
    ///- Parameter averageCash: Average cash made out of all handbook entries
    ///- Parameter averageTrees: Average trees planted out of all handbook entries
    ///- Parameter averageDistanceTravelled: Average distance travelled out of all handbook entries
    ///- Parameter averageTimeSecondsPlanting: Average time spent planting out of all handbook entries
    init(averageCash: Double, averageTrees: Int, averageDistanceTravelled: Double, averageTimeSecondsPlanting: Int){
        self.averageCash = averageCash
        self.averageTrees = averageTrees
        self.averageDistanceTravelled = averageDistanceTravelled
        self.averageTimeSecondsPlanting = averageTimeSecondsPlanting
    }
    
    ///Contructor for base entries
    init() {
        self.averageCash = 0
        self.averageTrees = 0
        self.averageDistanceTravelled = 0
        self.averageTimeSecondsPlanting = 0
    }
    
}
