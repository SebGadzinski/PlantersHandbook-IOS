//
//  ManagerView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class ManagerView: TableViewActionViewController {
    
    internal let titleLabel = SUI_Label(title: "", fontSize: FontSize.largeTitle)
    internal let nameTextField = SUI_TextField_Form(placeholder: "", textType: .name)
    internal let addButton = PH_Button(title: "Add Something", fontSize: FontSize.large)
    internal var managerTableView = SUI_TableView()
    
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        [titleLabel].forEach{titleLayout.addSubview($0)}
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    internal override func setUpActionLayout(){
        super.setUpActionLayout()
        let actionFrame = actionLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(50)
        
        [nameTextField, addButton].forEach{actionLayout.addSubview($0)}

        nameTextField.anchor(top: actionLayout.topAnchor, leading: actionLayout.leadingAnchor, bottom: nil, trailing: actionLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        nameTextField.anchorCenterX(to: actionLayout)
        self.nameTextField.delegate = self
        nameTextField.textAlignment = .center
        
        addButton.anchor(top: nameTextField.bottomAnchor, leading: nil, bottom: actionLayout.bottomAnchor, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: actionFrame.width*0.6, height: 0))
        addButton.anchorCenterX(to: actionLayout)
    }
    
    internal override func setUpTableViewLayout(){
        super.setUpTableViewLayout()
        [managerTableView].forEach{tableViewLayout.addSubview($0)}

        managerTableView.anchor(top: tableViewLayout.topAnchor, leading: tableViewLayout.leadingAnchor, bottom: tableViewLayout.bottomAnchor, trailing: tableViewLayout.trailingAnchor, padding: .init(top: 20, left: 0, bottom: 0, right: 0))
        managerTableView.rowHeight = 70
    }
    
}
