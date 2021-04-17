//
//  SeasonStatistics.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import Foundation

///SeasonStatistics.swift - All information needed for statistics from a season
struct SeasonStatistics{
    var seasonName : String
    var totalCash : Double
    var totalTrees : Int
    var totalDistanceTravelled : Double
    var totalTimeSecondsPlanting : Int
    var bestEntryStats : HandbookEntryStatistics?
    var averages : AverageSeasonStatistics
    var handbookEntrysStatistics : [HandbookEntryStatistics]
    
    ///Parameterized contructor that initalizes all fields all fields
    ///- Parameter seasonName: Seasons name
    ///- Parameter totalCash: Total cash season made
    ///- Parameter totalTrees: Total trees planted in season
    ///- Parameter totalDistanceTravelled: Total distance travelled in season
    ///- Parameter totalTimeSecondsPlanting: Total seconds planted in season
    ///- Parameter bestEntryStats: Best Handbook Entry inside season
    ///- Parameter averages: Average season statistics
    ///- Parameter handbookEntrysStatistics: All HandbookEntry statisics
    init(seasonName: String, totalCash: Double, totalTrees: Int, totalDistanceTravelled: Double, totalTimeSecondsPlanting: Int, bestEntryStats: HandbookEntryStatistics, averages: AverageSeasonStatistics, handbookEntrysStatistics: [HandbookEntryStatistics]){
        self.seasonName = seasonName
        self.totalCash = totalCash
        self.totalTrees = totalTrees
        self.totalDistanceTravelled = totalDistanceTravelled
        self.totalTimeSecondsPlanting = totalTimeSecondsPlanting
        self.bestEntryStats = bestEntryStats
        self.averages = averages
        self.handbookEntrysStatistics = handbookEntrysStatistics
    }
    
    ///Parameterized contructor that initalizes just the season field, and all other fields get base value
    ///- Parameter seasonName: Seasons name
    init(seasonName: String){
        self.seasonName = seasonName
        self.totalCash = 0
        self.totalTrees = 0
        self.totalDistanceTravelled = 0
        self.totalTimeSecondsPlanting = 0
        self.bestEntryStats = nil
        self.averages = AverageSeasonStatistics()
        self.handbookEntrysStatistics = []
    }
}
