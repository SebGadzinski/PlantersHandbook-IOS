//
//  OverallStatsCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

class OverallStatsCell: CardCell {
    
    let titleLabel = SUI_Label(title: "Title", fontSize: FontSize.large)
    let seasonTitleLabel = SUI_Label(title: "Season", fontSize: FontSize.meduim)
    let bestCashLabel = SUI_Label(title: "$ 0", fontSize: FontSize.large)
    let bestTreesLabel = SUI_Label(title: "0", fontSize: FontSize.large)
    let worstCashLabel = SUI_Label(title: "$ 0", fontSize: FontSize.large)
    let worstTreesLabel = SUI_Label(title: "0", fontSize: FontSize.large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        let totalCashTitleLabel = PH_Label_Stat(title: "Best")
        let totalTreesTitleLabel = PH_Label_Stat(title: "Average")
        
        [seasonTitleLabel, titleLabel, totalCashTitleLabel, bestCashLabel, bestTreesLabel, totalTreesTitleLabel, worstCashLabel, worstTreesLabel].forEach{containerView.addSubview($0)}
        
        seasonTitleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: hambugarMenu.leadingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 5), size: .init(width: 0, height: 0))
        seasonTitleLabel.anchorCenterY(to: hambugarMenu)
        seasonTitleLabel.textAlignment = .right
        seasonTitleLabel.textColor = .systemGreen
        
        titleLabel.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: seasonTitleLabel.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        titleLabel.anchorCenterY(to: hambugarMenu)
        titleLabel.textAlignment = .left
        
        totalCashTitleLabel.anchor(top: titleLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: 0, height: containerView.frame.height*0.15))
        totalCashTitleLabel.anchorCenterX(to: containerView)
        bestCashLabel.anchor(top: totalCashTitleLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.centerXAnchor, size: .init(width: 0, height: containerView.frame.height*0.25))
        bestTreesLabel.anchor(top: totalCashTitleLabel.bottomAnchor, leading: bestCashLabel.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor)
        bestTreesLabel.anchorSize(to: bestTreesLabel)
        bestTreesLabel.textColor = .systemGreen
        
        totalTreesTitleLabel.anchor(top: bestTreesLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil)
        totalTreesTitleLabel.anchorSize(to: totalCashTitleLabel)
        totalTreesTitleLabel.anchorCenterX(to: containerView)
        worstCashLabel.anchor(top: totalTreesTitleLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.centerXAnchor)
        worstTreesLabel.anchorSize(to: bestTreesLabel)
        worstTreesLabel.anchor(top: totalCashTitleLabel.bottomAnchor, leading: bestCashLabel.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor)
        worstTreesLabel.anchorSize(to: bestTreesLabel)
        worstTreesLabel.textColor = .systemGreen
        
    }

}
