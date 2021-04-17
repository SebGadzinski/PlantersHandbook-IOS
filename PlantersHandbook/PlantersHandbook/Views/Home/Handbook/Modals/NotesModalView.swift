//
//  NotesModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

///NotesModalView.swift - View for NotesModalViewController
class NotesModalView: GeneralView {    
    internal let titleLabel = SUI.label(title: "Notes", fontSize: FontSize.largeTitle)
    internal var notesField = SUI.textViewEditableBox(text: "", fontSize: FontSize.medium)
    
    ///Set up title layout within general view controller
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        notesField.accessibilityLabel = "NotesTextView"
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    ///Set up info layout within general view controller
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        infoLayout.addSubview(notesField)
        
        notesField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 50, right: 10))
        notesField.inputAccessoryView = toolBar

    }

}
