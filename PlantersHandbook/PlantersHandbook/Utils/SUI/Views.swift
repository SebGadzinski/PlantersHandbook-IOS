//
//  Views.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import Foundation
import UIKit

///Views.swift - All custom made UIViews given in static functions from SUI
extension SUI{
    ///Creates a programic general UIView
    ///- Parameter backgoundColor: Background color of view
    ///- Returns: Customized UIView
    static func view(backgoundColor: UIColor?) -> UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if let goodBackgroundColor = backgoundColor{
            view.backgroundColor = goodBackgroundColor
        }
        return view
    }

    ///Creates a underlined bar UIView
    ///- Parameter color: Background color of bar
    ///- Returns: Underlined bar UIView
    static func underlineBar(color: UIColor?) -> UIView {
        let bb = UIView()
        bb.translatesAutoresizingMaskIntoConstraints = false
        bb.backgroundColor = (color != nil ? color :.label)
        bb.layer.cornerRadius = CornerRaduis.small
        return bb
    }
}


