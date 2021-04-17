//
//  StackView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-03-08.
//

import Foundation
import UIKit

///StackViews.swift - All custom made UIStackViews given in static functions from SUI
extension SUI{
    ///Creates a programic UIStackView
    ///- Returns: Customized UIStackView
    static func stackView() -> UIStackView{
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 5
        stackView.backgroundColor = .systemBackground
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
