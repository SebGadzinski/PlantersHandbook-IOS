//
//  HandbookView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

///HandbookView.swift - View for HandbookViewController
class HandbookView: TableViewActionView {

    internal let dateLabel = SUI.labelDate(fontSize: FontSize.largeTitle)
    internal let addEntryButton = PHUI.button(title: "Add Work Day", fontSize: FontSize.large)
    internal let addSeasonButton = PHUI.button(title: "Add Season", fontSize: FontSize.medium)
    internal var seasonTableView = SUI.tableView()
    internal var handbookEntrysTableView = SUI.tableView()
    internal var logoutButton = PHUI.button(title: "Logout", fontSize: FontSize.medium)

    override func setUpOverlay() {
        super.setUpOverlay()
        seasonTableView.accessibilityLabel = "Seasons"
        handbookEntrysTableView.accessibilityLabel = "HandbookEntrys"
        
    }
    
    ///Set up title layout within manager view controller
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        [dateLabel, logoutButton].forEach{titleLayout.addSubview($0)}

        logoutButton.anchor(top: nil, leading: titleLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 5, bottom: 0, right: 0), size: .init(width: titleLayout.safeAreaFrame.width*0.2, height: titleLayout.safeAreaFrame.height*0.4))
        logoutButton.anchorCenterY(to: dateLabel)
        logoutButton.setTitleColor(.secondaryLabel, for: .normal)
        
        dateLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        dateLabel.anchorCenter(to: titleLayout)
    }
    
    ///Set up action layout within manager view controller
    internal override func setUpActionLayout(){
        super.setUpActionLayout()
        [addEntryButton, addSeasonButton].forEach{actionLayout.addSubview($0)}

        addEntryButton.anchor(top: actionLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0),size: .init(width: actionLayout.safeAreaFrame.width/2, height: actionLayout.safeAreaFrame.height/2))
        addEntryButton.anchorCenterX(to: actionLayout)
        
        addSeasonButton.anchor(top: addEntryButton.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 20, left: 0, bottom: 0, right: 0),size: .init(width: actionLayout.safeAreaFrame.width/4, height: actionLayout.safeAreaFrame.height/4))
        addSeasonButton.anchorCenterX(to: actionLayout)
    }
    
    ///Set up title table within manager view controller
    internal override func setUpTableViewLayout(){
        super.setUpTableViewLayout()
        [seasonTableView, handbookEntrysTableView].forEach{tableViewLayout.addSubview($0)}

        seasonTableView.rowHeight = 70
        handbookEntrysTableView.rowHeight = 50
        
        seasonTableView.anchor(top: tableViewLayout.topAnchor, leading: tableViewLayout.leadingAnchor, bottom: backgroundView.safeAreaLayoutGuide.bottomAnchor, trailing: nil, size: .init(width: tableViewLayout.safeAreaFrame.width/2, height: tableViewLayout.safeAreaFrame.height))
        
        handbookEntrysTableView.anchor(top: tableViewLayout.topAnchor, leading: seasonTableView.trailingAnchor, bottom: backgroundView.safeAreaLayoutGuide.bottomAnchor, trailing: tableViewLayout.trailingAnchor, size: .init(width: tableViewLayout.safeAreaFrame.width/2, height: tableViewLayout.safeAreaFrame.height))
    }
}
