//
//  GraphCardCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

///GraphCardCell.swift - Card cell with a graph 
class GraphCardCell: CardCell {
    let graphView = SUI.view(backgoundColor: .clear)
    let graphTitle = SUI.label(title: "Title", fontSize: FontSize.large)
    let graphSubTitle = SUI.label(title: "Sub Title", fontSize: FontSize.medium)
    let seasonTitle = SUI.label(title: "Season", fontSize: FontSize.large)
    var seasonSelected = 0
    
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
        
        [graphTitle, seasonTitle, graphSubTitle, graphView].forEach{containerView.addSubview($0)}
        
        seasonTitle.anchor(top: nil, leading: nil, bottom: nil, trailing: hamburgerMenu.leadingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 5), size: .init(width: 0, height: 0))
        seasonTitle.anchorCenterY(to: hamburgerMenu)
        seasonTitle.textAlignment = .right
        
        graphTitle.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: seasonTitle.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        graphTitle.anchorCenterY(to: hamburgerMenu)
        graphTitle.textAlignment = .left
        
        graphSubTitle.anchor(top: graphTitle.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: hamburgerMenu.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        graphSubTitle.textAlignment = .left
        
        graphView.anchor(top: graphSubTitle.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
    }

}
