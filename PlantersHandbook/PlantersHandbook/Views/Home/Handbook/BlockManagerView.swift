//
//  BlockManagerView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

///BlockManagerView.swift - View for BlockManagerViewController
class BlockManagerView: ManagerViewController<Block, HandbookEntry>{
    internal let extraCashButton = PHUI.button(title: "Extra $", fontSize: FontSize.large)
    internal let notesButton = PHUI.button(title: "Notes", fontSize: FontSize.large)
    
    override func setUpOverlay() {
        super.setUpOverlay()
        managerTableView.accessibilityLabel = "Blocks"
        nameTextField.accessibilityLabel = "BlockName"
    }
    
    ///Set up title layout within manager view controller
    override func setUpTitleLayout() {
        super.setUpTitleLayout()
        [extraCashButton, notesButton].forEach{titleLayout.addSubview($0)}
        notesButton.anchor(top: nil, leading: titleLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 5, bottom: 0, right: 0),size: .init(width: titleLayout.safeAreaFrame.width*0.2, height: titleLayout.safeAreaFrame.height*0.4))
        notesButton.anchorCenterY(to: titleLayout)
        
        extraCashButton.anchor(top: nil, leading: nil, bottom: nil, trailing: titleLayout.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        extraCashButton.anchorSize(to: notesButton)
        extraCashButton.anchorCenterY(to: titleLayout)
    }
}
