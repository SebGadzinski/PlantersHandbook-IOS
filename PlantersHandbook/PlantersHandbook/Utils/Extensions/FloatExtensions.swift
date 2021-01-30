//
//  FloatExtensions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-30.
//

import Foundation

extension Float {
    func round(to places: Int) -> String{
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf.string(from: NSNumber(value: self))!
    }
}
