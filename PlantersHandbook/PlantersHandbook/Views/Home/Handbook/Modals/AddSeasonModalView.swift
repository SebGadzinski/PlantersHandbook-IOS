//
//  SeasonModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class AddSeasonModalView: GeneralViewController {
    internal let titleLabel = SUI_Label(title: "Add Season", fontSize: FontSize.largeTitle)
    internal let seasonNameTextField = SUI_TextField_Form(placeholder: "", textType: .name)
    internal let addButton = PH_Button(title: "Add", fontSize: FontSize.large)

    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        let infoFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(50)
        
        [seasonNameTextField, addButton].forEach{infoLayout.addSubview($0)}
        
        seasonNameTextField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        seasonNameTextField.anchorCenterX(to: infoLayout)
        seasonNameTextField.textAlignment = .center
        
        addButton.anchor(top: seasonNameTextField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 30, left: 0, bottom: 0, right: 0),size: .init(width: infoFrame.width*0.4, height: 0))
        addButton.anchorCenterX(to: infoLayout)
    }
    
}
