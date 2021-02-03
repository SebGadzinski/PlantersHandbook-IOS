//
//  UILabels.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

func SUI_Label(title: String?, fontSize: Float?) -> UILabel {
    let lb = UILabel()
    lb.text = (title != nil ? title :"")
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize != nil ? fontSize! : FontSize.meduim))
    lb.adjustsFontSizeToFitWidth = true
    lb.textAlignment = .center
    return lb
}

func SUI_Label_Date(fontSize: Float?) -> UILabel {
    let lb = UILabel()
    lb.text = getDate(from: Date())
    lb.textAlignment = .center
    lb.adjustsFontSizeToFitWidth = true
    lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize!))
    return lb
}

func PH_Label_Number(title: String?) -> UILabel {
    let lb = UILabel()
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.adjustsFontSizeToFitWidth = true
    lb.text = (title != nil ? title :"")
    lb.textAlignment = .center
    lb.textColor = .label
    lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
    return lb
}
