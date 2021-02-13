//
//  Functions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import Foundation
import RealmSwift

struct GeneralFunctions{
    static func getDate(from: Date) -> String {
        let curDate = Calendar.current.dateComponents([.year,.day,.month], from: from)
        return String(curDate.year!) + " " + getMonth(month: curDate.month!) + " " +  String(curDate.day!)
    }

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
            return "Jun."
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

    static func createAdvancedTallyCell(cell: TallyCell, toolBar: UIToolbar, tag: Int, keyboardType: UIKeyboardType){
        cell.input.inputAccessoryView = toolBar
        cell.input.tag = tag
        cell.input.keyboardType = keyboardType
    }

    static func integer(from textField: UITextField) -> Int {
        guard let text = textField.text, let number = Int(text) else {
            return 0
        }
        return number
    }

    static func containsLetters(input: String) -> Bool {
       for chr in input {
          if ((chr >= "a" && chr <= "z") || (chr >= "A" && chr <= "Z") ) {
             return true
          }
       }
       return false
    }

    static func totalDensityFromArray(plotArray: List<PlotInput>) -> Float{
        var totalPlots = Float()
        var totalPlotsDensity = Float()
        for i in 0..<plotArray.count{
            totalPlots += (plotArray[i].inputOne > 0 ? 1 : 0)
            totalPlots += (plotArray[i].inputTwo > 0 ? 1 : 0)
            totalPlotsDensity += Float(plotArray[i].inputOne)
            totalPlotsDensity += Float(plotArray[i].inputTwo)
        }
        return (totalPlotsDensity != 0 ? (totalPlotsDensity/totalPlots) * 200 : 0)
    }

    static func longPressGestureHandlerMethod(imageView: UIImageView, recognizer:UIPinchGestureRecognizer){
        switch recognizer.state {
        case .began:
            UIView.animate(withDuration: 0.05,
                           animations: {
                            imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            },
                           completion: nil)
        case .ended:
            UIView.animate(withDuration: 0.05) {
                imageView.transform = CGAffineTransform.identity
            }
        default: break
        }
    }
    
    
    static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

