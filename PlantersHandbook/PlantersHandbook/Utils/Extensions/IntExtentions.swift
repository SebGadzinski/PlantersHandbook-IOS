//
//  IntExtentions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-03-23.
//

import Foundation

extension Int{
    func rounding(nearest:Float) -> Int{
        return Int(nearest * round(Float(self)/nearest))
    }
}

