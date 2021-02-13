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
}

struct FontSize{
    static let extraSmall = Float(UIScreen.main.bounds.height*0.018)
    static let small = Float(UIScreen.main.bounds.height*0.021)
    static let medium = Float(UIScreen.main.bounds.height*0.026)
    static let large = Float(UIScreen.main.bounds.height*0.031)
    static let extraLarge = Float(UIScreen.main.bounds.height*0.035)
    static let largeTitle = Float(UIScreen.main.bounds.height*0.04)
}

struct TallyNumbers{
    static let bagUpRows = 20
    static let columns = 8
}

struct StatisticColors{
    static let text = UIColor.label
    static let trees = UIColor.systemGreen
    static let cash = UIColor.systemIndigo
    static let distance = UIColor.systemOrange
//    static let lightBackground = UIColor.init(red: 221/255, green: 255/255, blue: 211/255, alpha: 1.0) //Light Green
    static let lightBackground = UIColor.white
    static let darkBackground = UIColor.black
    static let cardLight = UIColor.secondarySystemBackground
    static let cardDark = UIColor.secondarySystemBackground
}

struct CornerRaduis{
    static let small = CGFloat(5)
    static let medium = CGFloat(20)
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
    static let requiredInputValuesAmount : Double = 12.0
}

