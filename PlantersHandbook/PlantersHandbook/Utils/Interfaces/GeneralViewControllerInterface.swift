//
//  GeneralLayout.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-11.
//

import Foundation

///GeneralViewControllerInterface.swift - Protocols for a generic programic view controller
protocol GeneralViewInterface{
    ///Sets up  the views in the title layout
    func setUpTitleLayout()
    ///Sets up  the views in the Info which is  the rest of the screen after title layout
    func setUpInfoLayout()
}
