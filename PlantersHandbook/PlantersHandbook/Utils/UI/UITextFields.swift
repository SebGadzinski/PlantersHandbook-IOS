//
//  UITextFields.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit
import UnderLineTextField

func textField_form(placeholder: String?, textType: UITextContentType!) -> UnderLineTextField{
    let textField = UnderLineTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.activeLineColor = PHColors.green
    textField.textContentType = textType
    textField.isSecureTextEntry = (textType == UITextContentType.password || textType == UITextContentType.newPassword)
    textField.placeholderFont = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
    textField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.meduim))
    textField.placeholder = (placeholder != nil ? placeholder! : "")
    textField.errorFont = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraSmall))
    textField.errorTextColor = UIColor.red
    return textField
}

func textField_bagUp() -> UITextField {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.backgroundColor = .systemBackground
    textField.textColor = .label
    textField.borderStyle = .none
    textField.backgroundColor = .systemBackground
    textField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.meduim))
    textField.layer.masksToBounds = true
    textField.textAlignment = .center
    textField.autocorrectionType = .no
    textField.adjustsFontSizeToFitWidth = true
    textField.minimumFontSize = 10
    textField.clipsToBounds = true
    return textField
}
