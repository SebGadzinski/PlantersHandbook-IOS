//
//  TextFields.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit
import UnderLineTextField

///TextFields.swift - All custom made UITextFields given in static functions from SUI
extension SUI{
    ///Creates programic UnderLineTextField 
    ///- Parameter placeholder: A placeholder for the textfield
    ///- Parameter textType: Type of text to be written in textfield
    ///- Returns: A underlined textfield
    static func textFieldUnderlined(placeholder: String?, textType: UITextContentType!) -> UnderLineTextField{
        let textField = UnderLineTextField()
        textField.accessibilityLabel = placeholder
        textField.inactivePlaceholderTextColor = .gray
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.activeLineColor = UIColor.systemGreen
        textField.textContentType = textType
        textField.isSecureTextEntry = (textType == UITextContentType.password || textType == UITextContentType.newPassword)
        textField.placeholderFont = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
        textField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.medium))
        textField.placeholder = (placeholder != nil ? placeholder! : "")
        textField.errorFont = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraSmall))
        textField.errorTextColor = UIColor.red
        return textField
    }
}

