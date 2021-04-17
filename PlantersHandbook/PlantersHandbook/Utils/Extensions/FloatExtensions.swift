//
//  FloatExtensions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-30.
//

import Foundation

///FloatExtensions.swift - All custom made functions/attributes for Float
extension Float {
    ///Rounds number to place given
    ///- Parameter places: Desired rounding place
    ///- Returns: Rounded number as a string
    func round(to places: Int) -> String{
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf.string(from: NSNumber(value: self))!
    }
}
