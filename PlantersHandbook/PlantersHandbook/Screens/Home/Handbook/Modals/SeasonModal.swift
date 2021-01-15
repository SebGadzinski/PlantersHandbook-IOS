//
//  SeasonPickingModal.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-15.
//

import UIKit

class SeasonModal: ProgramicVC {
    weak var delegate : SeasonModal_Delegate?
    fileprivate var titleLayout : UIView!
    fileprivate var infoLayout : UIView!
    fileprivate var submitLayout : UIView!
    fileprivate let titleLb = label_normal(title: "Add Season", fontSize: FontSize.large)
    fileprivate let seasonNameInput = textField_form(placeholder: "", textType: .name)
    fileprivate let addButton = ph_button(title: "Add", fontSize: FontSize.large)
    
    override func generateLayout(){
        titleLayout = generalLayout(backgoundColor: .secondarySystemBackground)
        infoLayout = generalLayout(backgoundColor: .secondarySystemBackground)
    }
    
    override func configureViews(){
        setUpOverlay()
        setUpTitleLayout()
        setUpInfoLayout()
        keyboardMoveUpWhenTextFieldTouched = 0
    }
    
    override func setActions(){
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    func setUpOverlay(){
        bgView.backgroundColor = .secondarySystemBackground
        
        let frame = bgView.safeAreaFrame
        
        [titleLayout, infoLayout].forEach{bgView.addSubview($0)}
        
        titleLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.1))
        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.55))
    }
    
    func setUpTitleLayout(){
        titleLayout.addSubview(titleLb)
        
        titleLb.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLb.anchorCenter(to: titleLayout)
    }
    
    func setUpInfoLayout(){
        let infoFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(50)
        
        [seasonNameInput, addButton].forEach{infoLayout.addSubview($0)}
        
        seasonNameInput.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        seasonNameInput.anchorCenterX(to: infoLayout)
        self.seasonNameInput.delegate = self
        seasonNameInput.textAlignment = .center
        
        addButton.anchor(top: seasonNameInput.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 30, left: 0, bottom: 0, right: 0),size: .init(width: infoFrame.width*0.4, height: infoFrame.height*0.2))
        addButton.anchorCenterX(to: infoLayout)
    }
    
   
    
    @objc func addButtonAction(_ sender: Any) {
        if(seasonNameInput.text != ""){
            let newSeason = Season(partition: "user="+app.currentUser!.id, title: seasonNameInput.text!)

            if let delegate = delegate{
                delegate.createSeason(season: newSeason)
            }
            self.dismiss(animated: true, completion: nil)
            // Dismiss current Viewcontroller and back to Original
            self.navigationController?.popViewController(animated: true)
        }
    }

}

protocol SeasonModal_Delegate:NSObjectProtocol {
    func createSeason(season : Season)
}

