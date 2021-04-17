//
//  Buttons.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

///Buttons.swift - All custom made UIButtons given in static functions from SUI
extension SUI{
    ///Creates a programic general UIButton
    ///- Parameter title: Text in button
    ///- Parameter textColor: Type of text to be written in textfield
    ///- Parameter backgroundColor: Background color of button
    ///- Parameter fontSize: Font size for the text in the button
    ///- Parameter borderColor: Border color of button
    ///- Returns: Customized UIButton
    static func button(title: String?, textColor: UIColor?, backgroundColor: UIColor?, fontSize: Float?, borderColor: CGColor?) -> UIButton {
        let btn = UIButton()
        btn.setTitle((title != nil ? title! :""), for: .normal)
        btn.setTitleColor((textColor != nil ? textColor! : .black), for: .normal)
        btn.backgroundColor = (backgroundColor != nil ? backgroundColor! : .clear)
        btn.titleLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat((fontSize != nil ? fontSize! : FontSize.medium)))
        btn.layer.borderColor = (borderColor != nil ? borderColor! : UIColor.black.cgColor)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.adjustsFontForContentSizeCategory = true
        //For recording purposes
        btn.showsTouchWhenHighlighted = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }

    ///Creates a programic  rounded UIButton
    ///- Parameter title: Text in button
    ///- Parameter textColor: Type of text to be written in textfield
    ///- Parameter backgroundColor: Background color of button
    ///- Parameter fontSize: Font size for the text in the button
    ///- Parameter borderColor: Border color of button
    ///- Parameter raduis: Raduis of button
    ///- Parameter borderWidth: Border line thickness
    ///- Returns: Customized Rounded Button
    static func buttonRounded(title: String?, textColor: UIColor?, backgroundColor: UIColor?, fontSize: Float?, borderColor: CGColor?, radius: CGFloat, borderWidth: CGFloat) -> UIButton {
        let btn = button(title: title, textColor: textColor, backgroundColor: backgroundColor, fontSize: fontSize, borderColor: borderColor)
        btn.layer.cornerRadius = radius
        btn.layer.borderWidth = borderWidth
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return btn
    }
}
