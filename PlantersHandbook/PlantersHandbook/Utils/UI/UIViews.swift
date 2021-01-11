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


