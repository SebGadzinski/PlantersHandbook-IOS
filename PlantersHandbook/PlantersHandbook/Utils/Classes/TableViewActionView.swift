//
//  TableViewActionViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-11.
//

import UIKit

///TableViewActionViewController.swift - Sets up generic programic table view controller
class TableViewActionView: ProgrammaticViewController, TableViewActionViewInterface {

    internal var titleLayout = SUI.view(backgoundColor: .systemBackground)
    internal var actionLayout = SUI.view(backgoundColor: .systemBackground)
    internal var tableViewLayout = SUI.view(backgoundColor: .systemBackground)
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpTitleLayout()
        setUpActionLayout()
        setUpTableViewLayout()
    }
    
    ///Set up overlay of view for all views in programic view controller
    internal override func setUpOverlay() {
        super.setUpOverlay()
        let frame = backgroundView.safeAreaFrame
        
        [titleLayout, actionLayout, tableViewLayout].forEach{backgroundView.addSubview($0)}
        
        titleLayout.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: frame.width, height: frame.height*0.1))
        
        actionLayout.anchor(top: titleLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.20))
        tableViewLayout.anchor(top: actionLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.70))
    }
    
    ///Set up title layout within manager view controller
    internal func setUpTitleLayout() {
    }
    
    ///Set up action layout within manager view controller
    internal func setUpActionLayout() {
    }
    
    ///Set up title table within manager view controller
    internal func setUpTableViewLayout() {
    }
    


}
