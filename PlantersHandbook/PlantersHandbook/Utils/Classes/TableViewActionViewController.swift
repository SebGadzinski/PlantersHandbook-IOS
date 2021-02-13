//
//  TableViewActionViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-11.
//

import UIKit

class TableViewActionViewController: ProgramicVC, TableViewActionViewControllerInterface {

    internal var titleLayout = SUI_View(backgoundColor: .systemBackground)
    internal var actionLayout = SUI_View(backgoundColor: .systemBackground)
    internal var tableViewLayout = SUI_View(backgoundColor: .systemBackground)
    
    internal override func configureViews() {
        super.configureViews()
        setUpTitleLayout()
        setUpActionLayout()
        setUpTableViewLayout()
    }
    
    internal override func setUpOverlay() {
        super.setUpOverlay()
        let frame = backgroundView.safeAreaFrame
        
        [titleLayout, actionLayout, tableViewLayout].forEach{backgroundView.addSubview($0)}
        
        titleLayout.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: frame.width, height: frame.height*0.1))
        
        actionLayout.anchor(top: titleLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.20))
        tableViewLayout.anchor(top: actionLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.70))
    }
    
    internal func setUpTitleLayout() {
        print("setUpTitleLayout")
    }
    
    internal func setUpActionLayout() {
        print("setUpActionLayout")
    }
    
    internal func setUpTableViewLayout() {
        print("setUpTableViewLayout")
    }
    


}
