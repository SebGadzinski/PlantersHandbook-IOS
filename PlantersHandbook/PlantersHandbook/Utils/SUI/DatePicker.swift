//
//  DatePicker.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-03-08.
//

import Foundation
import UIKit

///DatePicker.swift - All custom made UIDatePicker given in static functions from SUI
extension SUI{
    
    ///Creates a programic UIDatePicker
    ///- Returns: Customized UIDatePicker
    static func datePicker() -> UIDatePicker{
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.date = Date()
        dp.maximumDate = Date()
        return dp
    }
}
