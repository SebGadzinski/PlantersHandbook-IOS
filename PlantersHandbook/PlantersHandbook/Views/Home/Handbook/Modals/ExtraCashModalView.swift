//
//  ExtraCashModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

///ExtraCashModalView.swift - View for ExtraCashModalViewController
class ExtraCashModalView: GeneralView {
    internal let titleLabel = SUI.label(title: "Extra Cash", fontSize: FontSize.largeTitle)
    internal var reasonTextField = SUI.textViewEditableBox(text: "", fontSize: FontSize.medium)
    internal let cashTextField = SUI.textFieldUnderlined(placeholder: "", textType: .none)
    internal let extraCashButton = PHUI.button(title: "Add Extra Cash", fontSize: FontSize.large)
    internal var tableView = SUI.tableView()
    
    override func setUpOverlay() {
        super.setUpOverlay()
        reasonTextField.accessibilityLabel = "ReasonTextView"
        cashTextField.accessibilityLabel = "CashTextField"
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
        let frame = infoLayout.safeAreaFrame
        
        [reasonTextField, cashTextField, extraCashButton, tableView].forEach{infoLayout.addSubview($0)}
        
        reasonTextField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: frame.height*0.2))
        reasonTextField.layer.borderWidth = 3
        reasonTextField.layer.borderColor = UIColor.systemGray.cgColor
        reasonTextField.inputAccessoryView = toolBar
        reasonTextField.text = "My reason for this extra cash is..."
        reasonTextField.textColor = .label
        
        cashTextField.anchor(top: reasonTextField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: frame.width*0.3, height: 0))
        cashTextField.anchorCenterX(to: infoLayout)
        cashTextField.keyboardType = .decimalPad
        cashTextField.inputAccessoryView = toolBar
        cashTextField.textAlignment = .center
        cashTextField.inactivePlaceholderTextColor = .label
        cashTextField.text = "50"
        
        extraCashButton.anchor(top: cashTextField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: frame.width*0.5, height: frame.height*0.08))
        extraCashButton.anchorCenterX(to: infoLayout)
        
        tableView.anchor(top: extraCashButton.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 50, right: 0),size: .init(width: frame.width, height: 0))
        tableView.rowHeight = 50
    }

}
