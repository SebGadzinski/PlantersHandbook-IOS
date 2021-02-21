//
//  BlockManagerView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class BlockManagerView: ManagerView {
    internal let extraCashButton = PH_Button(title: "Extra $", fontSize: FontSize.large)
    internal let notesButton = PH_Button(title: "Notes", fontSize: FontSize.large)
    
    override func setUpTitleLayout() {
        super.setUpTitleLayout()
        [extraCashButton, notesButton].forEach{titleLayout.addSubview($0)}
        notesButton.anchor(top: nil, leading: titleLayout.leadingAnchor, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width*0.2, height: titleLayout.safeAreaFrame.height*0.4))
        notesButton.anchorCenterY(to: titleLayout)
        
        extraCashButton.anchor(top: nil, leading: nil, bottom: nil, trailing: titleLayout.trailingAnchor)
        extraCashButton.anchorSize(to: notesButton)
        extraCashButton.anchorCenterY(to: titleLayout)
    }
}
