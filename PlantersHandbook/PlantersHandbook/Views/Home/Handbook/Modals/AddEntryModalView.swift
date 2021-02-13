//
//  AddEntryModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-12.
//

import UIKit

class AddEntryModalView: GeneralViewController {

    internal let titleLabel = SUI_Label(title: "Add Entry", fontSize: FontSize.largeTitle)
    internal let datePicker = SUI_DatePicker()
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
        
        [datePicker, addButton].forEach{infoLayout.addSubview($0)}
        
        datePicker.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: infoFrame.width, height: infoFrame.height*0.6))
        datePicker.anchorCenterX(to: infoLayout)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        
        
        
        addButton.anchor(top: datePicker.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 30, left: 0, bottom: 0, right: 0),size: .init(width: infoFrame.width*0.4, height: 0))
        addButton.anchorCenterX(to: infoLayout)
    }

}
