//
//  NotesModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

class NotesModalView: GeneralViewController {    
    internal let titleLabel = SUI_Label(title: "Notes", fontSize: FontSize.largeTitle)
    internal var notesField = SUI_TextView_EditableBox(text: "", fontSize: FontSize.medium)
    
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        infoLayout.addSubview(notesField)
        
        notesField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 50, right: 10))
        notesField.layer.borderWidth = 3
        notesField.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        notesField.inputAccessoryView = toolBar
    }

}
