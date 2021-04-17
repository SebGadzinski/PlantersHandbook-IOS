//
//  ManagerInterface.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-04-05.
//

import Foundation
import UIKit
import RealmSwift

///TableViewActionViewControllerInterface.swift - Protocols for a generic progrmic table view controller
@objc protocol ManagerInterface{
    //Action when hamburger menu tapped on manager entry
    @objc func hamburgerMenuTapped(sender: UIButton)
    ///Sets up the table delegates
    func setUpTableDelegates() -> Void
    ///Adds a object to the manager
    @objc func addAction() -> Void
}
