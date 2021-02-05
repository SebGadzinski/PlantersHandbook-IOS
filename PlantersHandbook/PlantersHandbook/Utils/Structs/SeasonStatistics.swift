//
//  SeasonStatistics.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import Foundation

struct SeasonStatistics{
    var seasonName : String
    var totalCash : Double
    var totalTrees : Int
    var totalDistanceTravelled : Double
    var bestEntryStats : HandbookEntryStatistics?
    var averages : AverageSeasonStatistics
    var handbookEntrysStatistics : [HandbookEntryStatistics]
    
    init(seasonName: String, totalCash: Double, totalTrees: Int, totalDistanceTravelled: Double, bestEntryStats: HandbookEntryStatistics, averages: AverageSeasonStatistics, handbookEntrysStatistics: [HandbookEntryStatistics]){
        self.seasonName = seasonName
        self.totalCash = totalCash
        self.totalTrees = totalTrees
        self.totalDistanceTravelled = totalDistanceTravelled
        self.bestEntryStats = bestEntryStats
        self.averages = averages
        self.handbookEntrysStatistics = handbookEntrysStatistics
    }
    
    init(seasonName: String){
        self.seasonName = seasonName
        self.totalCash = 0
        self.totalTrees = 0
        self.totalDistanceTravelled = 0
        self.bestEntryStats = nil
        self.averages = AverageSeasonStatistics()
        self.handbookEntrysStatistics = []
    }
}
