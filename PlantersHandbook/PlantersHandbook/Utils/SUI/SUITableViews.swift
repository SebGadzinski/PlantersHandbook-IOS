//
//  UITableViews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

func SUI_TableView() -> UITableView{
    let tv = UITableView(frame: .zero)
    tv.backgroundColor = .systemBackground
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    return tv
}
