//
//  UILabels.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

func label_normal(title: String?, fontSize: Float?) -> UILabel {
    let lb = UILabel()
    lb.text = (title != nil ? title :"")
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize != nil ? fontSize! : FontSize.meduim))
    lb.adjustsFontSizeToFitWidth = true
    lb.textAlignment = .center
    return lb
}

func label_date(fontSize: Float?) -> UILabel {
    let lb = UILabel()
    lb.text = getDate(from: Date())
    lb.textAlignment = .center
    lb.adjustsFontSizeToFitWidth = true
    lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize!))
    return lb
}
