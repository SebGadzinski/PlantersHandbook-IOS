//
//  ProgramicViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation

///ProgramicVCInterface.swift - Protocols for a programic view controller
protocol ProgramicViewInterface{
    ///Sets up the overalll layout of all the views
    func setUpOverlay() -> Void
    ///Configures all the views that the view controller contains
    func configureViews() -> Void
}
