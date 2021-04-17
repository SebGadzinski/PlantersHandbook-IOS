//
//  Functions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import Foundation
import RealmSwift

///GeneralFunctions.swift - Contains static functions that are used accross many classes in the system
struct GeneralFunctions{
    ///Creates a string from a date
    ///- Parameter from: Date to be converted to string
    ///- Returns: String of date in format "Year Month Day"
    static func getDate(from: Date) -> String {
        let curDate = Calendar.current.dateComponents([.year,.day,.month], from: from)
        return String(curDate.year!) + " " + getMonth(month: curDate.month!) + " " +  String(curDate.day!)
    }

    ///Gets name of month related to number
    ///- Parameter month: Month in number form  (0-11)
    ///- Returns: Name of month
    static func getMonth(month: Int) -> String{
        if(month == 1){
            return "Jan."
        }
        else if (month == 2){
            return "Feb."
        }
        else if (month == 3){
            return "Mar."
        }
        else if (month == 4){
            return "Apr."
        }
        else if (month == 5){
            return "May."
        }
        else if (month == 6){
            return "Jun."
        }
        else if (month == 7){
            return "Jul."
        }
        else if (month == 8){
            return "Aug."
        }
        else if (month == 9){
            return "Sep."
        }
        else if (month == 10){
            return "Oct."
        }
        else if (month == 11){
            return "Nov."
        }
        else{
            return "Dec."
        }
    }

    ///Gets integer from textfield if it contains only a integer
    ///- Parameter textField: Textfield that contains a  integer
    ///- Returns: Integer from textfield
    static func integer(from textField: UITextField) -> Int {
        guard let text = textField.text, let number = Int(text) else {
            return 0
        }
        return number
    }
    
    ///Gets density from a list containing plots
    ///- Parameter plotArray: List of plots
    ///- Returns: Density from plots
    static func totalDensityFromArray(plotArray: List<PlotInput>) -> Double{
        var totalPlots = Double()
        var totalPlotsDensity = Double()
        for i in 0..<plotArray.count{
            totalPlots += (plotArray[i].inputOne > 0 ? 1 : 0)
            totalPlots += (plotArray[i].inputTwo > 0 ? 1 : 0)
            totalPlotsDensity += Double(plotArray[i].inputOne)
            totalPlotsDensity += Double(plotArray[i].inputTwo)
        }
        return (totalPlotsDensity != 0.0 ? ((totalPlotsDensity/totalPlots) * 200.0) : 0.0)
    }
    
    ///Gets total value of all plots given in list of plots
    ///- Parameter plotArray: List of plots
    ///- Returns: Total value of all plots
    static func totalPlotsValueFromArray(plotArray: List<PlotInput>) -> Double{
        var totalPlotsValue = Double()
        for i in 0..<plotArray.count{
            totalPlotsValue += Double(plotArray[i].inputOne)
            totalPlotsValue += Double(plotArray[i].inputTwo)
        }
        return totalPlotsValue
    }
    
    ///Gets total value of all plots given in list of plots
    ///- Parameter plots: Number of plots
    ///- Parameter plotsValue: Value from all plots
    ///- Returns: Total value of all plots
    static func calculateDensity(plots: Double, plotsValue: Double) -> Double{
        return ( plots > 0 ? (plotsValue/plots) * 200 : 0)
    }
    
    ///Gets total number of input slots used from list of PlotInputs
    ///- Parameter plotArray: List of plots
    ///- Returns: Total number of input slots used from list of PlotInputs
    static func totalPlotsFromArray(plotArray: List<PlotInput>) -> Double{
        var totalPlots = Double()
        for i in 0..<plotArray.count{
            totalPlots += (plotArray[i].inputOne > 0 ? 1 : 0)
            totalPlots += (plotArray[i].inputTwo > 0 ? 1 : 0)
        }
        return totalPlots
    }
    
    ///Converts seconds toHours | minutes | Seconds
    ///- Parameter seconds: Seconds to be converted
    ///- Returns: 3 ints, (Hours, Minutes, Seconds)
    static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    ///Converts seconds to Days | Hours | minutes | Seconds
    ///- Parameter seconds: Seconds to be converted
    ///- Returns: 4 ints, (Days, Hours, Minutes, Seconds)
    static func secondsToDaysHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
      return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 86400) % 3600 / 60, (seconds % 86400) % 3600 % 60)
    }
    
    ///Adjusts the height of a textView to match its length in words
    ///- Parameter arg: UITextView to have its hieght adjusted
    static func adjustUITextViewHeight(arg : UITextView){
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
}

