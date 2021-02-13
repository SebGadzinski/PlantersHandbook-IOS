//
//  OverallStatsCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

class OverallStatsCell: CardCell {
    
    let titleLabel = SUI_Label(title: "Title", fontSize: FontSize.large)
    let seasonTitleLabel = SUI_Label(title: "Season", fontSize: FontSize.large)
    let bestCashLabel = SUI_Label(title: "$ 0", fontSize: FontSize.extraLarge)
    let bestTreesLabel = SUI_Label(title: "0", fontSize: FontSize.extraLarge)
    let averageCashLabel = SUI_Label(title: "$ 0", fontSize: FontSize.extraLarge)
    let averageTreesLabel = SUI_Label(title: "0", fontSize: FontSize.extraLarge)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        let bestLabel = PH_Label_Stat(title: "Best")
        let averageLabel = PH_Label_Stat(title: "Average")
        
        [seasonTitleLabel, titleLabel, bestLabel, bestCashLabel, bestTreesLabel, averageLabel, averageCashLabel, averageTreesLabel].forEach{containerView.addSubview($0)}
        
        seasonTitleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: hamburgerMenu.leadingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 5), size: .init(width: 0, height: 0))
        seasonTitleLabel.anchorCenterY(to: hamburgerMenu)
        seasonTitleLabel.textAlignment = .right
        
        titleLabel.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: seasonTitleLabel.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        titleLabel.anchorCenterY(to: hamburgerMenu)
        titleLabel.textAlignment = .left
        
        bestLabel.anchor(top: titleLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil)
        bestLabel.anchorCenterX(to: containerView)
        
        bestCashLabel.anchor(top: bestLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.centerXAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        bestCashLabel.textColor = StatisticColors.cash
        
        bestTreesLabel.anchor(top: bestLabel.bottomAnchor, leading: bestCashLabel.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        bestTreesLabel.anchorSize(to: bestTreesLabel)
        bestTreesLabel.textColor = StatisticColors.trees
        
        averageLabel.anchor(top: bestTreesLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        averageLabel.anchorSize(to: bestLabel)
        averageLabel.anchorCenterX(to: containerView)
        
        averageCashLabel.anchor(top: averageLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.centerXAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        averageCashLabel.anchorSize(to: bestTreesLabel)
        averageCashLabel.textColor = StatisticColors.cash
        
        averageTreesLabel.anchor(top: averageLabel.bottomAnchor, leading: bestCashLabel.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        averageTreesLabel.anchorSize(to: bestTreesLabel)
        averageTreesLabel.textColor = StatisticColors.trees
        
    }

}
