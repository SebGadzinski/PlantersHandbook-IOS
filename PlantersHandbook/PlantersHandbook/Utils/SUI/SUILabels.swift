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

// Custom Developed For Planters Handbook

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

func PH_Label_Stat(title: String?) -> UILabel{
    let lb = SUI_Label(title: title, fontSize: FontSize.meduim)
    lb.font = UIFont(name: Fonts.avenirNextMeduimBold, size: CGFloat(FontSize.meduim))
    if let newTitle = title{
        let lbString = NSAttributedString(string: newTitle,
                                                  attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        lb.attributedText = lbString
    }
    return lb
}
