//
//  Config.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-03.
//

// This is where general configuration variables are, within there relative structs

import Foundation
import UIKit

struct Fonts{
    static let avenirNextMeduim = "AvenirNext-Medium"
    static let avenirNextMeduimBold = "AvenirNext-Medium-Bold"
}

struct FontSize{
//    static let extraSmall = Float(12)
//    static let small = Float(16)
//    static let meduim = Float(20)
//    static let large = Float(24)
//    static let extraLarge = Float(30)
    static let extraSmall = Float(UIScreen.main.bounds.height*0.018)
    static let small = Float(UIScreen.main.bounds.height*0.021)
    static let meduim = Float(UIScreen.main.bounds.height*0.026)
    static let large = Float(UIScreen.main.bounds.height*0.031)
    static let extraLarge = Float(UIScreen.main.bounds.height*0.035)
    static let largeTitle = Float(UIScreen.main.bounds.height*0.04)
}

struct TallyNumbers{
    static let bagUpRows = 20
    static let columns = 8
}

struct PHColors{
    static let green = UIColor.systemGreen
    static let gray = UIColor.systemGray
    static let background = UIColor.systemBackground
    static let secondaryBackground = UIColor.secondarySystemBackground
    static let clear = UIColor.clear
    static let label = UIColor.label
}

struct CornerRaduis{
    static let small = CGFloat(5)
    static let meduim = CGFloat(20)
    static let large = CGFloat(50)
}

struct BorderWidth{
    static let extraThin = CGFloat(2)
    static let thin = CGFloat(5)
    static let thick = CGFloat(10)
    static let extraThick = CGFloat(20)
}

struct ChartNumbers{
    static let visibleRandMaximum : Double = 12.0
    static let requiredInputValuesAmount : Int = 12
}

