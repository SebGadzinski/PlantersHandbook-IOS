//
//  GetNameView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-04-09.
//

import UIKit

class GetNameView: GeneralView{
    
    internal var nameLayout = SUI.view(backgoundColor: .systemBackground)
    internal let nameTextField = SUI.textFieldUnderlined(placeholder: "Name", textType: .name)

    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icon.png"))
    internal let titleLabel = SUI.label(title: "Full Name", fontSize: FontSize.extraLarge)
    internal let infoMessage = SUI.textViewMultiLine(text: "This will be the name on the printed day sheet that you can give to your foreman", fontSize: FontSize.extraSmall)
    internal let confirmButton = PHUI.button(title: "Confirm", fontSize: FontSize.large)
    
    ///Called after the controller's view is loaded into memory.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        keyboardMoveWhenTextFieldTouched = 150
    }
    
    ///Set up title layout within general view controller
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
    
    ///Set up info layout within general view controller
    internal override func setUpInfoLayout() {
        super.setUpInfoLayout()
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(80)
        
        [nameLayout, confirmButton].forEach{infoLayout.addSubview($0)}
        
        nameLayout.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: confirmButton.topAnchor, trailing: infoLayout.trailingAnchor)
        
        [nameTextField].forEach{nameLayout.addSubview($0)}
        
        nameTextField.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        nameTextField.delegate = self
        nameTextField.anchorCenterY(to: nameLayout)
        nameTextField.inactivePlaceholderTextColor = .label
        nameTextField.autocorrectionType = .no
        
        confirmButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.2, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: infoLayoutFrame.height*0.1))
    }
    
}
