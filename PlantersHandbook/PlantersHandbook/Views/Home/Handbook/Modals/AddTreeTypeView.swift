//
//  AddTreeTypeView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-06-21.
//

import UIKit

class AddTreeTypeModalView: GeneralView {
    
    internal let titleLabel = SUI.label(title: "Add Tree Type", fontSize: FontSize.largeTitle)
    internal let typeTextField = SUI.textFieldUnderlined(placeholder: "Type", textType: .name)
    internal var typeLayout = SUI.view(backgoundColor: .systemBackground)
    internal var typePickerView = UIPickerView()
    internal let otherTypeTextField = SUI.textFieldUnderlined(placeholder: "Other Type", textType: .name)
    internal let requestTextField = SUI.textFieldUnderlined(placeholder: "Request Key", textType: .name)
    internal let confirmButton = PHUI.button(title: "Confirm", fontSize: FontSize.large)

    override func setUpOverlay() {
        super.setUpOverlay()
    }

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
        
        let textFieldUnderlineWidthSpacingMultiplier : CGFloat = 0.6
        let textFieldUnderlineHeightSpacingMultiplier : CGFloat = 0.25
        let textFieldBoundarySpace : CGFloat = (CGFloat(view.frame.width) * (CGFloat(1.0) - textFieldUnderlineWidthSpacingMultiplier))/2

        [typeLayout, otherTypeTextField, requestTextField, confirmButton].forEach{infoLayout.addSubview($0)}
        typeLayout.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, size: .init(width: 0, height: infoLayout.frame.height * 0.10))
        [typeTextField, typePickerView, otherTypeTextField].forEach{typeLayout.addSubview($0)}
        
        typeTextField.anchor(top: nil, leading: typeLayout.leadingAnchor, bottom: nil, trailing: typeLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        typeTextField.anchorCenterY(to: typeLayout)
        typeTextField.anchorCenterX(to: typeLayout)
        typeTextField.inactiveLineColor = .systemGreen
        
        typePickerView.fillSuperView()
        typePickerView.isHidden = true
        
        otherTypeTextField.anchor(top: typeTextField.bottomAnchor, leading: typeLayout.leadingAnchor, bottom: nil, trailing: typeLayout.trailingAnchor, padding: .init(top: -10, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        otherTypeTextField.isHidden = true
        otherTypeTextField.inactiveLineColor = .systemGreen
        
        requestTextField.anchor(top: typeLayout.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        requestTextField.autocapitalizationType = .allCharacters
        requestTextField.inactiveLineColor = .systemGreen
        
        confirmButton.anchor(top: requestTextField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 50, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: infoLayout.frame.height*0.15))
        confirmButton.anchorCenterX(to: infoLayout)
    }

}
