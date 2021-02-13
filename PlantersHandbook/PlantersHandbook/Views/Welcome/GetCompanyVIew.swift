//
//  GetCompanyVIew.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class GetCompanyView: GeneralViewController{

    internal var companyLayout = SUI_View(backgoundColor: .systemBackground)
    internal var companyPickerView = UIPickerView()

    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    internal let companyTitleLabel = SUI_Label(title: "Company", fontSize: FontSize.extraLarge)
    internal let companyInfoMessage = SUI_TextView_MultiLine(text: "Please select the company you work for", fontSize: FontSize.medium)
    internal let companyTextField = SUI_TextField_Form(placeholder: "Click to choose", textType: .name)
    internal let confirmButton = PH_Button(title: "Confirm", fontSize: FontSize.large)
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        keyboardMoveUpWhenTextFieldTouched = 150
    }
    
    internal override func setUpTitleLayout() {
        super.setUpTitleLayout()
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, companyTitleLabel, companyInfoMessage].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        companyTitleLabel.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        companyTitleLabel.anchorCenterX(to: titleLayout)
        
        companyInfoMessage.anchor(top: companyTitleLabel.bottomAnchor, leading: titleLayout.leadingAnchor, bottom: titleLayout.bottomAnchor, trailing: titleLayout.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 5), size: .init(width: 0, height: titleLayoutFrame.height*0.2))
        companyInfoMessage.anchorCenterX(to: titleLayout)
        companyInfoMessage.textAlignment = .center
        
    }
    
    internal override func setUpInfoLayout() {
        super.setUpInfoLayout()
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [companyLayout, confirmButton].forEach{infoLayout.addSubview($0)}
        
        companyLayout.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: confirmButton.topAnchor, trailing: infoLayout.trailingAnchor)
        
        [companyTextField, companyPickerView].forEach{companyLayout.addSubview($0)}
        
        companyTextField.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        companyTextField.delegate = self
        companyTextField.anchorCenterY(to: companyLayout)
        
        companyPickerView.anchor(top: companyLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: companyLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 10, right: 0))
        companyPickerView.isHidden = true
        
        confirmButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.2, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: infoLayoutFrame.height*0.1))
    }
    
}
