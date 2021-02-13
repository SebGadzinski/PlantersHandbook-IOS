//
//  UIViews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import Foundation
import UIKit

func SUI_View(backgoundColor: UIColor?) -> UIView{
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    if let goodBackgroundColor = backgoundColor{
        view.backgroundColor = goodBackgroundColor
    }
    return view
}

func SUI_View_ScrollViewContent() -> UIView {
    let scrollCV = UIView()
    scrollCV.translatesAutoresizingMaskIntoConstraints = false
    scrollCV.backgroundColor = .systemBackground
    return scrollCV
}

func SUI_View_UnderlineBar(color: UIColor?) -> UIView {
    let bb = UIView()
    bb.translatesAutoresizingMaskIntoConstraints = false
    bb.backgroundColor = (color != nil ? color :.label)
    bb.layer.cornerRadius = CornerRaduis.small
    return bb
}

func SUI_DatePicker() -> UIDatePicker{
    let dp = UIDatePicker()
    dp.translatesAutoresizingMaskIntoConstraints = false
    dp.date = Date()
    dp.maximumDate = Date()
    return dp
}



