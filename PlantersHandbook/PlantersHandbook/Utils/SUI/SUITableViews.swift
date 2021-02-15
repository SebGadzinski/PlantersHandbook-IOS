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

func SUI_TableView_Editable() -> UITableView{
    let tv = UITableView(frame: .zero)
    tv.backgroundColor = .systemBackground
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.register(EditableTableViewCell.self, forCellReuseIdentifier: "EditCell")
    return tv
}
