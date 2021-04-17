//
//  Labels.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

///Labels.swift - All custom made UILabels given in static functions from SUI
extension SUI{
    ///Creates a programic general UILabel
    ///- Parameter title: Text in button
    ///- Parameter fontSize: Font size for the text in the button
    ///- Returns: Customized UILabel
    static func label(title: String?, fontSize: Float?) -> UILabel {
        let lb = UILabel()
        lb.text = (title != nil ? title :"")
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize != nil ? fontSize! : FontSize.medium))
        lb.adjustsFontSizeToFitWidth = true
        lb.textAlignment = .center
        return lb
    }

    ///Creates a programic UILabel that contains todays date
    ///- Parameter fontSize: Font size for the text in the button
    ///- Returns: Customized UILabel
    static func labelDate(fontSize: Float?) -> UILabel {
        let lb = UILabel()
        lb.text = GeneralFunctions.getDate(from: Date())
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize!))
        return lb
    }

    ///Creates a programic UILabel that contains todays date
    ///- Parameter title: Text in button
    ///- Parameter fontSize: Font size for the text in the button
    ///- Parameter numberOfLines: Number of lines the label will contain
    ///- Returns: Customized UILabel
    static func labelMutliLine(text: String?, fontSize: Float, numberOfLines: Int) -> UILabel  {
        let lb = UILabel()
        lb.text = (text != nil ? text :"")
        lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize))
        lb.numberOfLines = numberOfLines
        lb.textColor = .label
        lb.adjustsFontSizeToFitWidth = true
        lb.textAlignment = .center
        lb.sizeToFit()
        return lb
    }
}
