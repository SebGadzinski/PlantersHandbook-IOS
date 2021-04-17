//
//  TableViews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

///TableViews.swift - All custom made UITableViews given in static functions from SUI
extension SUI{
    ///Creates a programic UITableView 
    ///- Returns: Customized UITableView
    static func tableView() -> UITableView{
        let tv = UITableView(frame: .zero)
        tv.backgroundColor = .systemBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tv
    }

    ///Creates a programic editable UITableView that uses EditableTableViewCell as its cells
    ///- Returns: Customized UITableView
    static func tableViewEditable() -> UITableView{
        let tv = UITableView(frame: .zero)
        tv.backgroundColor = .systemBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(EditableTableViewCell.self, forCellReuseIdentifier: "EditCell")
        return tv
    }
}
