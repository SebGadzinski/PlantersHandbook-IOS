//
//  GetStepLengthView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-14.
//

import UIKit

class GetStepLengthView: GeneralViewController{

    internal var stepDistanceLayout = SUI_View(backgoundColor: .systemBackground)
    internal var stepDistancePickerView = UIPickerView()

    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    internal let titleLabel = SUI_Label(title: "Step Length", fontSize: FontSize.extraLarge)
    internal let infoMessage = SUI_TextView_MultiLine(text: "For best calculations, we ask you to give us your distance per step", fontSize: FontSize.extraSmall)
    internal let stepDistanceTextField = SUI_TextField_Form(placeholder: "Step Distance (CM)", textType: .name)
    internal let confirmButton = PH_Button(title: "Confirm", fontSize: FontSize.large)
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        keyboardMoveUpWhenTextFieldTouched = 150
    }
    
    internal override func setUpTitleLayout() {
        super.setUpTitleLayout()
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, titleLabel, infoMessage].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        titleLabel.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        titleLabel.anchorCenterX(to: titleLayout)
        
        infoMessage.anchor(top: titleLabel.bottomAnchor, leading: titleLayout.leadingAnchor, bottom: titleLayout.bottomAnchor, trailing: titleLayout.trailingAnchor, padding: .init(top: -10, left: 5, bottom: 0, right: 5), size: .init(width: 0, height: titleLayoutFrame.height*0.3))
        infoMessage.anchorCenterX(to: titleLayout)
        infoMessage.textAlignment = .center
    }
    
    internal override func setUpInfoLayout() {
        super.setUpInfoLayout()
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(80)
        
        [stepDistanceLayout, confirmButton].forEach{infoLayout.addSubview($0)}
        
        stepDistanceLayout.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: confirmButton.topAnchor, trailing: infoLayout.trailingAnchor)
        
        [stepDistanceTextField, stepDistancePickerView].forEach{stepDistanceLayout.addSubview($0)}
        
        stepDistanceTextField.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        stepDistanceTextField.delegate = self
        stepDistanceTextField.anchorCenterY(to: stepDistanceLayout)
        stepDistanceTextField.inactivePlaceholderTextColor = .label
        
        stepDistancePickerView.anchor(top: stepDistanceLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: stepDistanceLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 10, right: 0))
        stepDistancePickerView.isHidden = true
        
        confirmButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.1, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: infoLayoutFrame.height*0.1))
    }
    
}
