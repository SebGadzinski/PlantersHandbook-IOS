//
//  GraphCardCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

class GraphCardCell: CardCell {
    let graphView = SUI_View(backgoundColor: .clear)
    let graphTitle = SUI_Label(title: "Title", fontSize: FontSize.large)
    let graphSubTitle = SUI_Label(title: "Sub Title", fontSize: FontSize.meduim)
    let seasonTitle = SUI_Label(title: "Season", fontSize: FontSize.large)
    var seasonSelected = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        
        [graphTitle, seasonTitle, graphSubTitle, graphView].forEach{containerView.addSubview($0)}
        
        seasonTitle.anchor(top: nil, leading: nil, bottom: nil, trailing: hambugarMenu.leadingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 5), size: .init(width: 0, height: 0))
        seasonTitle.anchorCenterY(to: hambugarMenu)
        seasonTitle.textAlignment = .right
        seasonTitle.textColor = .systemGreen
        
        graphTitle.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: seasonTitle.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        graphTitle.anchorCenterY(to: hambugarMenu)
        graphTitle.textAlignment = .left
        
        graphSubTitle.anchor(top: graphTitle.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: hambugarMenu.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        graphSubTitle.textAlignment = .left
        
        graphView.anchor(top: graphSubTitle.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
    }

}
