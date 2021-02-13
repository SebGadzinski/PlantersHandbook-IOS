//
//  OneTotalCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-13.
//

import UIKit

class OneTotalCell: CardCell {

    let titleLabel = SUI_Label(title: "Totals", fontSize: FontSize.large)
    let seasonTitleLabel = SUI_Label(title: "Season", fontSize: FontSize.large)
    let totalLabel = PH_Label_Stat(title: "Total")
    let largeTotalLabel = SUI_Label(title: "0", fontSize: FontSize.largeTitle)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        
        [seasonTitleLabel, titleLabel, totalLabel, largeTotalLabel].forEach{containerView.addSubview($0)}
        
        seasonTitleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: hamburgerMenu.leadingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 5), size: .init(width: 0, height: 0))
        seasonTitleLabel.anchorCenterY(to: hamburgerMenu)
        seasonTitleLabel.textAlignment = .right
        
        titleLabel.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: seasonTitleLabel.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        titleLabel.anchorCenterY(to: hamburgerMenu)
        titleLabel.textAlignment = .left
        
        totalLabel.anchor(top: titleLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil,  padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        totalLabel.anchorCenterX(to: containerView)
        
        largeTotalLabel.anchor(top: totalLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: frame.height*0.4))
    }
    
    

}
