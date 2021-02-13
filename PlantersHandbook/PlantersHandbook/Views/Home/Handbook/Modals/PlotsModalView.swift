//
//  PlotsModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class PlotsModalView: GeneralViewController {
    
    internal let titleLabel = SUI_Label(title: "Plots", fontSize: FontSize.largeTitle)
    internal let densityLabel = SUI_Label(title: "Density: ", fontSize: FontSize.large)
    internal var plotsCollectionView = PH_CollectionView_Plots()
    
//    override func setUpOverlay() {
//        super.setUpOverlay()
//        let frame = backgroundView.safeAreaFrame
//
//        [titleLayout, infoLayout].forEach{backgroundView.addSubview($0)}
//
//        titleLayout.anchor(top: backgroundView.topAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.15))
//        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.6))
//    }
    
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
    
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        let infoFrame = infoLayout.safeAreaFrame.size
        
        infoLayout.addSubview(plotsCollectionView)
        plotsCollectionView.anchor(top: infoLayout.topAnchor, leading: nil, bottom: infoLayout.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: infoFrame.height*0.2, right: 0), size: .init(width: infoFrame.width*0.7, height: 0))
        plotsCollectionView.contentInset = .init(top: 0, left: 0, bottom: infoFrame.height*0.5, right: 0)
        plotsCollectionView.centerXAnchor.constraint(equalTo: infoLayout.centerXAnchor).isActive = true
    }

    
}
