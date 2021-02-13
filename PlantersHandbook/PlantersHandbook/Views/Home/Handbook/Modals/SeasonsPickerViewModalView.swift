//
//  SeasonsPickerViewModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit
import M13Checkbox

class SeasonsPickerViewModalView: GeneralViewController {
    
    internal let titleLabel = SUI_Label(title: "Seasons", fontSize: FontSize.largeTitle)
    internal var seasonsPickerView = UIPickerView()
    internal var changeAllGraphsCheckBox = M13Checkbox(frame: .zero)
    internal let confirmButton = PH_Button(title: "Confirm", fontSize: FontSize.large)
    internal let checkBoxLabel = SUI_Label(title: "Change All Graphs", fontSize: FontSize.medium)
    
    override func configureViews() {
        super.configureViews()
        setUpTitleLayout()
        setUpInfoLayout()
    }
    
    internal override func setUpTitleLayout() {
        super.setUpTitleLayout()
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    internal override func setUpInfoLayout() {
        super.setUpInfoLayout()
        [seasonsPickerView, changeAllGraphsCheckBox, checkBoxLabel].forEach{infoLayout.addSubview($0)}
        
        
        seasonsPickerView.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 10, right: 0), size: .init(width: 0, height: infoLayout.safeAreaFrame.height*0.8))
        
        changeAllGraphsCheckBox.anchor(top: seasonsPickerView.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0),size: .init(width: 30, height: 30))
        changeAllGraphsCheckBox.boxType = .square
        changeAllGraphsCheckBox.stateChangeAnimation = .bounce(.fill)
        changeAllGraphsCheckBox.tintColor = .systemGreen
        
        checkBoxLabel.anchor(top: nil, leading: changeAllGraphsCheckBox.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 5, bottom: 0, right: 0),size: .init(width: 200, height: 50))
        checkBoxLabel.anchorCenterY(to: changeAllGraphsCheckBox)
    }

}
