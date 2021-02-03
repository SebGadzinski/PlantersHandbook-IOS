//
//  UIButtons.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

func SUI_Button_Normal(title: String?, textColor: UIColor?, backgroundColor: UIColor?, fontSize: Float?, borderColor: CGColor?) -> UIButton {
    let btn = UIButton()
    btn.setTitle((title != nil ? title! :""), for: .normal)
    btn.setTitleColor((textColor != nil ? textColor! : .black), for: .normal)
    btn.backgroundColor = (backgroundColor != nil ? backgroundColor! : .clear)
    btn.titleLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat((fontSize != nil ? fontSize! : FontSize.meduim)))
    btn.layer.borderColor = (borderColor != nil ? borderColor! : UIColor.black.cgColor)
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.titleLabel?.adjustsFontForContentSizeCategory = true
    //For recording purposes
    btn.showsTouchWhenHighlighted = true
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
}

func SUI_Button_Rounded(title: String?, textColor: UIColor?, backgroundColor: UIColor?, fontSize: Float?, borderColor: CGColor?, radius: CGFloat, borderWidth: CGFloat) -> UIButton {
    let btn = SUI_Button_Normal(title: title, textColor: textColor, backgroundColor: backgroundColor, fontSize: fontSize, borderColor: borderColor)
    btn.layer.cornerRadius = radius
    btn.layer.borderWidth = borderWidth
    btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    return btn
}

func PH_Button(title: String, fontSize: Float) -> UIButton{
    return SUI_Button_Rounded(title: title, textColor: PHColors.gray, backgroundColor: PHColors.clear, fontSize: fontSize, borderColor: PHColors.green.cgColor, radius: CornerRaduis.small, borderWidth: BorderWidth.extraThin)
}

func PH_Button_Tally(title: String, fontSize: Float, borderColor: CGColor) -> UIButton{
    let button = SUI_Button_Rounded(title: title, textColor: PHColors.gray, backgroundColor: PHColors.clear, fontSize: fontSize, borderColor: borderColor, radius: CornerRaduis.meduim, borderWidth: BorderWidth.extraThin)
    button.contentEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)
    return button
}

