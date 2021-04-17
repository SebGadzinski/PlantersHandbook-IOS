//
//  SubBlockManagerView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

///SubBlockManagerView.swift - View for SubBlockManagerViewController
class SubBlockManagerView: ManagerViewController<SubBlock, Block> {

    override func setUpOverlay() {
        super.setUpOverlay()
        managerTableView.accessibilityLabel = "SubBlocks"
        nameTextField.accessibilityLabel = "SubBlockName"
    }
    
}
