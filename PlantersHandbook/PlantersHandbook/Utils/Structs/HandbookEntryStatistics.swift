//
//  HandbookEntryStatistics.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import Foundation

struct HandbookEntryStatistics{
    var date : Date
    var totalCash : Double
    var totalTrees : Int
    var totalDistanceTravelled : Double
    var totalTimeSecondsPlanting : Int
    
    init(date: Date, totalCash: Double, totalTrees: Int, totalDistanceTravelled: Double, totalTimeSecondsPlanting: Int){
        self.date = date
        self.totalCash = totalCash
        self.totalTrees = totalTrees
        self.totalDistanceTravelled = totalDistanceTravelled
        self.totalTimeSecondsPlanting = totalTimeSecondsPlanting
    }
    
    init(date: Date){
        self.date = date
        self.totalCash = 0
        self.totalTrees = 0
        self.totalDistanceTravelled = 0
        self.totalTimeSecondsPlanting = 0
    }
    
}
