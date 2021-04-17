//
//  HandbookEntryStatistics.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import Foundation

///HandbookEntryStatistics.swift - All information needed for statistics from a handbookEntry
struct HandbookEntryStatistics{
    var date : Date
    var totalCash : Double
    var totalTrees : Int
    var totalDistanceTravelled : Double
    var totalTimeSecondsPlanting : Int
    
    ///Parameterized contructor that initalizes all fields all fields
    ///- Parameter averageCash: Average cash made out of all handbook entries
    ///- Parameter averageTrees: Average trees planted out of all handbook entries
    ///- Parameter averageDistanceTravelled: Average distance travelled out of all handbook entries
    ///- Parameter averageTimeSecondsPlanting: Average time spent planting out of all handbook entries
    init(date: Date, totalCash: Double, totalTrees: Int, totalDistanceTravelled: Double, totalTimeSecondsPlanting: Int){
        self.date = date
        self.totalCash = totalCash
        self.totalTrees = totalTrees
        self.totalDistanceTravelled = totalDistanceTravelled
        self.totalTimeSecondsPlanting = totalTimeSecondsPlanting
    }
    
    ///Contructor for base entries
    init(date: Date){
        self.date = date
        self.totalCash = 0
        self.totalTrees = 0
        self.totalDistanceTravelled = 0
        self.totalTimeSecondsPlanting = 0
    }
    
}
