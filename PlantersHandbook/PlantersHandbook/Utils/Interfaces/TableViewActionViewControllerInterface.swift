//
//  TableViewActionViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-11.
//

import Foundation

///TableViewActionViewControllerInterface.swift - Protocols for a generic progrmic table view controller
protocol TableViewActionViewInterface{
    ///Sets up  the views in the title layout
    func setUpTitleLayout() -> Void
    ///Sets up  the views in the action layout
    func setUpActionLayout() -> Void
    ///Sets up  the views in the title layout
    func setUpTableViewLayout() -> Void
}
