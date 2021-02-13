//
//  HandbookView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class HandbookView: TableViewActionViewController {

    internal let dateLabel = SUI_Label_Date(fontSize: FontSize.largeTitle)
    internal let addEntryButton = PH_Button(title: "Add Entry", fontSize: FontSize.large)
    internal let addSeasonButton = PH_Button(title: "Add Season", fontSize: FontSize.medium)
    internal var seasonTableView = SUI_TableView()
    internal var handbookEntrysTableView = SUI_TableView()
    internal var logoutButton = PH_Button(title: "Logout", fontSize: FontSize.medium)
    
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        [dateLabel, logoutButton].forEach{titleLayout.addSubview($0)}

        logoutButton.anchor(top: nil, leading: titleLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 5, bottom: 0, right: 0), size: .init(width: titleLayout.safeAreaFrame.width*0.2, height: titleLayout.safeAreaFrame.height*0.4))
        logoutButton.anchorCenterY(to: dateLabel)
        logoutButton.setTitleColor(.secondaryLabel, for: .normal)
        
        dateLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        dateLabel.anchorCenter(to: titleLayout)
    }
    
    internal override func setUpActionLayout(){
        super.setUpActionLayout()
        [addEntryButton, addSeasonButton].forEach{actionLayout.addSubview($0)}

        addEntryButton.anchor(top: actionLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0),size: .init(width: actionLayout.safeAreaFrame.width/2, height: actionLayout.safeAreaFrame.height/2))
        addEntryButton.anchorCenterX(to: actionLayout)
        
        addSeasonButton.anchor(top: addEntryButton.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 20, left: 0, bottom: 0, right: 0),size: .init(width: actionLayout.safeAreaFrame.width/4, height: actionLayout.safeAreaFrame.height/4))
        addSeasonButton.anchorCenterX(to: actionLayout)
    }
    
    internal override func setUpTableViewLayout(){
        super.setUpTableViewLayout()
        [seasonTableView, handbookEntrysTableView].forEach{tableViewLayout.addSubview($0)}

        seasonTableView.rowHeight = 70
        handbookEntrysTableView.rowHeight = 50
        
        seasonTableView.anchor(top: tableViewLayout.topAnchor, leading: tableViewLayout.leadingAnchor, bottom: backgroundView.safeAreaLayoutGuide.bottomAnchor, trailing: nil, size: .init(width: tableViewLayout.safeAreaFrame.width/2, height: tableViewLayout.safeAreaFrame.height))
        
        handbookEntrysTableView.anchor(top: tableViewLayout.topAnchor, leading: seasonTableView.trailingAnchor, bottom: backgroundView.safeAreaLayoutGuide.bottomAnchor, trailing: tableViewLayout.trailingAnchor, size: .init(width: tableViewLayout.safeAreaFrame.width/2, height: tableViewLayout.safeAreaFrame.height))
    }
}
