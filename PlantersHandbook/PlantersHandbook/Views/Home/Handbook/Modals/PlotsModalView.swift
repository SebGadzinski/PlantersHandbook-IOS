//
//  PlotsModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

///PlotsModalView.swift - View for PlotsModalViewController
class PlotsModalView: GeneralView {
    
    internal let titleLabel = SUI.label(title: "Plots", fontSize: FontSize.largeTitle)
    internal let densityLabel = SUI.label(title: "Density: ", fontSize: FontSize.large)
    internal var plotsCollectionView = PHUI.collectionViewPlots()
    
    ///Set up title layout within general view controller
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        titleLayout.addSubview(titleLabel)
        titleLayout.addSubview(densityLabel)
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.centerXAnchor.constraint(equalTo: titleLayout.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleLayout.centerYAnchor).isActive = true
        densityLabel.anchor(top: titleLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width, height: titleLayout.safeAreaFrame.height/4))
        densityLabel.anchorCenterX(to: titleLayout)
        densityLabel.font = UIFont(name: Fonts.avenirNextMeduim, size: 16)
    }
    
    ///Set up info layout within general view controller
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        let infoFrame = infoLayout.safeAreaFrame.size
        
        infoLayout.addSubview(plotsCollectionView)
        plotsCollectionView.anchor(top: infoLayout.topAnchor, leading: nil, bottom: infoLayout.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: infoFrame.height*0.2, right: 0), size: .init(width: infoFrame.width*0.7, height: 0))
        plotsCollectionView.contentInset = .init(top: 0, left: 0, bottom: infoFrame.height*0.5, right: 0)
        plotsCollectionView.centerXAnchor.constraint(equalTo: infoLayout.centerXAnchor).isActive = true
    }

    
}
