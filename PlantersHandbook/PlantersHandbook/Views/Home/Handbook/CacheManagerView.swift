//
//  CacheManagerView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

///CacheManagerView.swift - View for CacheManagerViewController
class CacheManagerView: ManagerViewController<Cache, SubBlock> {

    override func setUpOverlay() {
        super.setUpOverlay()
        managerTableView.accessibilityLabel = "Caches"
        nameTextField.accessibilityLabel = "CacheName"
    }
    
}
