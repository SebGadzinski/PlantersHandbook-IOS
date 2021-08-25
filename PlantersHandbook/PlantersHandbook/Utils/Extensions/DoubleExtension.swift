//
//  FloatExtension.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-21.
//

import Foundation

///DoubleExtensions.swift - All custom made functions/attributes for Double
extension Double{
    ///Converts Double into 2 decimal place Double and then to a String with $ infront
    ///Exp. 1234.1234 -> $1234.12
    ///- Returns: Currency form of double 
    func toCurrency() -> String{
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf.string(from: NSNumber(value: self))!
    }
    
    ///Converts Double into 2 decimal place Double and then to a String with $ infront
    ///Exp. 1234.1234 -> $1234.12
    ///- Returns: Currency form of double
    func toCurrency(numOfDecimals: Int?) -> String{
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        if let numOfDecimals = numOfDecimals{
            nf.minimumFractionDigits = numOfDecimals
            nf.maximumFractionDigits = numOfDecimals
        }
        return nf.string(from: NSNumber(value: self))!
    }
    
    ///Rounds number to place given
    ///- Parameter places: Desired rounding place
    ///- Returns: Rounded number
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

}

