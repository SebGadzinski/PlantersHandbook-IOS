//
//  TotalCashCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

///TotalCashCell.swift - Card cell with totals of cash and tree amounts
class TotalCashCell: CardCell {

    let titleLabel = SUI.label(title: "Totals", fontSize: FontSize.large)
    let totalCashAmountLabel = SUI.label(title: "$ 0", fontSize: FontSize.extraLarge)
    let totalTreesAmountLabel = SUI.label(title: "0", fontSize: FontSize.extraLarge)
    
    ///Constructor that sets up the frame of the cell
    ///- Parameter frame: Frame of cell (x and y locations on screen and size)
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Creates  layout for cell
    override func generateLayout(){
        super.generateLayout()
        
        let leftView = SUI.view(backgoundColor: .clear)
        let rightView = SUI.view(backgoundColor: .clear)
        
        [titleLabel, leftView, rightView].forEach{containerView.addSubview($0)}
        
        titleLabel.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: hamburgerMenu.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        titleLabel.anchorCenterY(to: hamburgerMenu)
        titleLabel.textAlignment = .left
        
        leftView.anchor(top: titleLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.centerXAnchor)
        
        rightView.anchor(top: titleLabel.bottomAnchor, leading: leftView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
        
        let totalCashTitleLabel = PHUI.labelStat(title: "Total Cash")
        let totalTreesTitleLabel = PHUI.labelStat(title: "Total Trees")
        
        [totalCashTitleLabel, totalTreesTitleLabel, totalCashAmountLabel, totalTreesAmountLabel].forEach{leftView.addSubview($0)}
        
        totalCashTitleLabel.anchor(top: leftView.topAnchor, leading: leftView.leadingAnchor, bottom: nil, trailing: leftView.trailingAnchor,size: .init(width: 0, height: leftView.frame.height*0.3))
        totalCashAmountLabel.anchor(top: totalCashTitleLabel.topAnchor, leading: leftView.leadingAnchor, bottom: leftView.bottomAnchor, trailing: leftView.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0),size: .init(width: 0, height: leftView.frame.height*0.65))
        totalCashTitleLabel.textAlignment = .center
        totalCashAmountLabel.textAlignment = .center
        totalCashAmountLabel.textColor = StatisticColors.cash
        
        totalTreesTitleLabel.anchor(top: rightView.topAnchor, leading: rightView.leadingAnchor, bottom: nil, trailing: rightView.trailingAnchor,size: .init(width: 0, height: leftView.frame.height*0.3))
        totalTreesAmountLabel.anchor(top: totalTreesTitleLabel.topAnchor, leading: rightView.leadingAnchor, bottom: rightView.bottomAnchor, trailing: rightView.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0),size: .init(width: 0, height: rightView.frame.height*0.65))
        totalTreesTitleLabel.textAlignment = .center
        totalTreesAmountLabel.textAlignment = .center
        totalTreesAmountLabel.textColor = StatisticColors.trees
        
    }
    
    

}
