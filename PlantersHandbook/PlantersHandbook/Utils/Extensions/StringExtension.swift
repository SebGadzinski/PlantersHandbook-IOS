//
//  StringExtension.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-21.
//

import Foundation

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    var doubleValue: Double {
            return (self as NSString).doubleValue
    }
}
