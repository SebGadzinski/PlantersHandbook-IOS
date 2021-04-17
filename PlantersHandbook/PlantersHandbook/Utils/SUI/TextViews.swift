//
//  TextView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-14.
//

import Foundation
import UIKit

///TextViews.swift - All custom made UITextViews given in static functions from SUI
extension SUI{
    ///Creates a programic multiline  UITextView
    ///- Parameter text: Text in button
    ///- Parameter fontSize: Font size for the text in the UITextView
    ///- Returns: Customized Multiline UITextView
    static func textViewMultiLine(text: String, fontSize: Float) -> UITextView{
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text;
        textView.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize))
        textView.adjustsFontForContentSizeCategory = true
        return textView
    }

    ///Creates a programic  rounded UITextView
    ///- Parameter text: Text in button
    ///- Parameter fontSize: Font size for the text in the UITextView
    ///- Returns: Customized rounded UITextView
    static func textViewRoundedBackground(text: String, fontSize: Float) -> UITextView{
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text;
        textView.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize))
        textView.adjustsFontForContentSizeCategory = true
        textView.layer.cornerRadius = CornerRaduis.medium
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.textAlignment = .center
        return textView
    }

    ///Creates a programic  rounded UITextView
    ///- Parameter text: text in button
    ///- Parameter fontSize: font size for the text in the UITextView
    ///- Returns: Customized rounded UITextView
    static func textViewEditableBox(text: String, fontSize: Float) -> UITextView {
        let textField = UITextView()
        textField.text = text
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isEditable = true
        textField.backgroundColor = .systemBackground
        textField.textColor = .label
        textField.textAlignment = .left
        textField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize))
        return textField
    }

}
