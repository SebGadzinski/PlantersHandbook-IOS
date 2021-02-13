//
//  UITextView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-14.
//

import Foundation
import UIKit

func SUI_TextView_MultiLine(text: String, fontSize: Float) -> UITextView{
    let textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.text = text;
    textView.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize))
    textView.adjustsFontForContentSizeCategory = true
    return textView
}

func SUI_TextView_RoundedBackground(text: String, fontSize: Float) -> UITextView{
    let textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.text = text;
    textView.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(fontSize))
    textView.adjustsFontForContentSizeCategory = true
    textView.layer.cornerRadius = CornerRaduis.medium
    textView.backgroundColor = .white
    textView.textColor = .black
    textView.textAlignment = .center
//    textView.layer.borderColor = UIColor.white.cgColor
//    textView.layer.borderWidth = 0.5
    return textView
}
