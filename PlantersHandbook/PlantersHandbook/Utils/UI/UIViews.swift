//
//  UIViews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import Foundation
import UIKit

func generalLayout(backgoundColor: UIColor?) -> UIView{
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    if let goodBackgroundColor = backgoundColor{
        view.backgroundColor = goodBackgroundColor
    }
    return view
}

func scrollContentViewNormal() -> UIView {
    let scrollCV = UIView()
    scrollCV.translatesAutoresizingMaskIntoConstraints = false
    scrollCV.backgroundColor = .systemBackground
    return scrollCV
}

func underLineBar(color: UIColor?) -> UIView {
    let bb = UIView()
    bb.translatesAutoresizingMaskIntoConstraints = false
    bb.backgroundColor = (color != nil ? color :.label)
    bb.layer.cornerRadius = CornerRaduis.small
    return bb
}



