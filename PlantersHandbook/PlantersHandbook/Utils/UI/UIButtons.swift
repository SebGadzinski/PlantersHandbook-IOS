//
//  UIButtons.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

func button_normal(title: String?, textColor: UIColor?, backgroundColor: UIColor?, fontSize: Float?, borderColor: CGColor?) -> UIButton {
    let btn = UIButton()
    btn.setTitle((title != nil ? title! :""), for: .normal)
    btn.setTitleColor((textColor != nil ? textColor! : .black), for: .normal)
    btn.backgroundColor = (backgroundColor != nil ? backgroundColor! : .clear)
    btn.titleLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat((fontSize != nil ? fontSize! : FontSize.meduim)))
    btn.layer.borderColor = (borderColor != nil ? borderColor! : UIColor.black.cgColor)
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    //For recording purposes
    btn.showsTouchWhenHighlighted = true
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
}

func button_rounded(title: String?, textColor: UIColor?, backgroundColor: UIColor?, fontSize: Float?, borderColor: CGColor?, radius: CGFloat, borderWidth: CGFloat) -> UIButton {
    let btn = button_normal(title: title, textColor: textColor, backgroundColor: backgroundColor, fontSize: fontSize, borderColor: borderColor)
    btn.layer.cornerRadius = radius
    btn.layer.borderWidth = borderWidth
    btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    return btn
}

func ph_button(title: String, fontSize: Float) -> UIButton{
    return button_rounded(title: title, textColor: PHColors.gray, backgroundColor: PHColors.clear, fontSize: fontSize, borderColor: PHColors.green.cgColor, radius: CornerRaduis.small, borderWidth: BorderWidth.extraThin)
}

