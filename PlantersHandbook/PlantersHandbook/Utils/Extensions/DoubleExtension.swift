//
//  FloatExtension.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-21.
//

import Foundation

extension Double{
    func toCurrency() -> String{
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf.string(from: NSNumber(value: self))!
    }
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
