//
//  TotalCashCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

class TotalCashCell: CardCell {

    let titleLabel = SUI_Label(title: "Totals", fontSize: FontSize.large)
    let totalCashAmountLabel = SUI_Label(title: "$ 0", fontSize: FontSize.large)
    let totalTreesAmountLabel = SUI_Label(title: "0", fontSize: FontSize.large)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        
        let leftView = SUI_View(backgoundColor: .clear)
        let rightView = SUI_View(backgoundColor: .clear)
        
        [titleLabel, leftView, rightView].forEach{containerView.addSubview($0)}
        
        titleLabel.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: hambugarMenu.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        titleLabel.anchorCenterY(to: hambugarMenu)
        titleLabel.textAlignment = .left
        
        leftView.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.centerXAnchor)
        
        rightView.anchor(top: titleLabel.bottomAnchor, leading: leftView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
        
        let totalCashTitleLabel = PH_Label_Stat(title: "Total Cash")
        let totalTreesTitleLabel = PH_Label_Stat(title: "Total Trees")
        
        [totalCashTitleLabel, totalTreesTitleLabel, totalCashAmountLabel, totalTreesAmountLabel].forEach{leftView.addSubview($0)}
        
        totalCashTitleLabel.anchor(top: leftView.topAnchor, leading: leftView.leadingAnchor, bottom: nil, trailing: leftView.trailingAnchor, size: .init(width: 0, height: leftView.frame.height*0.3))
        totalCashAmountLabel.anchor(top: totalCashTitleLabel.topAnchor, leading: leftView.leadingAnchor, bottom: leftView.bottomAnchor, trailing: leftView.trailingAnchor, size: .init(width: 0, height: leftView.frame.height*0.65))
        totalCashTitleLabel.textAlignment = .center
        totalCashAmountLabel.textAlignment = .center
        
        totalTreesTitleLabel.anchor(top: rightView.topAnchor, leading: rightView.leadingAnchor, bottom: nil, trailing: rightView.trailingAnchor, size: .init(width: 0, height: leftView.frame.height*0.3))
        totalTreesAmountLabel.anchor(top: totalTreesTitleLabel.topAnchor, leading: rightView.leadingAnchor, bottom: rightView.bottomAnchor, trailing: rightView.trailingAnchor, size: .init(width: 0, height: rightView.frame.height*0.65))
        totalTreesTitleLabel.textAlignment = .center
        totalTreesAmountLabel.textAlignment = .center
        
    }
    
    

}
