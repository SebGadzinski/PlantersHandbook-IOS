//
//  OneTextFieldModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

///OneTextFieldModalView.swift - View for OneTextFieldModalViewController
class OneTextFieldModalView: GeneralView {
    internal let titleLabel = SUI.label(title: "Title", fontSize: FontSize.largeTitle)
    internal let textField = SUI.textFieldUnderlined(placeholder: "", textType: .name)
    internal let confirmButton = PHUI.button(title: "Confirm", fontSize: FontSize.large)

    ///Set up title layout within general view controller
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    ///Set up info layout within general view controller
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        let infoFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(50)
        
        [textField, confirmButton].forEach{infoLayout.addSubview($0)}
        
        textField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        textField.anchorCenterX(to: infoLayout)
        textField.textAlignment = .center
        
        confirmButton.anchor(top: textField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 30, left: 0, bottom: 0, right: 0),size: .init(width: infoFrame.width*0.4, height: 0))
        confirmButton.anchorCenterX(to: infoLayout)
    }
    

}
