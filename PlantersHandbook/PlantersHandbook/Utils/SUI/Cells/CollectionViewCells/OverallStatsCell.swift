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
        let BestLabel = PH_Label_Stat(title: "Best")
        let AverageLabel = PH_Label_Stat(title: "Average")
        
        [seasonTitleLabel, titleLabel, BestLabel, bestCashLabel, bestTreesLabel, AverageLabel, averageCashLabel, averageTreesLabel].forEach{containerView.addSubview($0)}
        
        seasonTitleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: hambugarMenu.leadingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 5), size: .init(width: 0, height: 0))
        seasonTitleLabel.anchorCenterY(to: hambugarMenu)
        seasonTitleLabel.textAlignment = .right
        seasonTitleLabel.textColor = .systemGreen
        
        titleLabel.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: seasonTitleLabel.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        titleLabel.anchorCenterY(to: hambugarMenu)
        titleLabel.textAlignment = .left
        
        BestLabel.anchor(top: titleLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil)
        BestLabel.anchorCenterX(to: containerView)
        bestCashLabel.anchor(top: BestLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.centerXAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        bestTreesLabel.anchor(top: BestLabel.bottomAnchor, leading: bestCashLabel.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        bestTreesLabel.anchorSize(to: bestTreesLabel)
        bestTreesLabel.textColor = .systemGreen
        
        AverageLabel.anchor(top: bestTreesLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        AverageLabel.anchorSize(to: BestLabel)
        AverageLabel.anchorCenterX(to: containerView)
        averageCashLabel.anchor(top: AverageLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.centerXAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        averageCashLabel.anchorSize(to: bestTreesLabel)
        averageTreesLabel.anchor(top: AverageLabel.bottomAnchor, leading: bestCashLabel.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        averageTreesLabel.anchorSize(to: bestTreesLabel)
        averageTreesLabel.textColor = .systemGreen
        
    }

}
