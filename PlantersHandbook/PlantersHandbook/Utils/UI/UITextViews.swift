//
//  UITextView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-14.
//

import Foundation
import UIKit

func textView_multiLine(text: String, fontSize: Float) -> UITextView{
    let textField = UITextView()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.text = text;
    textField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize))
    textField.adjustsFontForContentSizeCategory = true
    return textField
}
