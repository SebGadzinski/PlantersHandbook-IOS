//
//  GeneralViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-11.
//

import UIKit

///GeneralViewController.swift - Sets up generic view controller
class GeneralView: ProgrammaticViewController, GeneralViewInterface {

    internal let titleLayout = SUI.view(backgoundColor: .systemBackground)
    internal let infoLayout = SUI.view(backgoundColor: .systemBackground)
    
    ///Set up overlay of view for all views in programic view controller
    internal override func setUpOverlay() {
        super.setUpOverlay()
        [titleLayout, infoLayout].forEach{backgroundView.addSubview($0)}
                
        titleLayout.anchor(top: backgroundView.topAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.25))
        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.7))
    }
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpTitleLayout()
        setUpInfoLayout()
    }
    
    ///Set up title layout within general view controller
    internal func setUpTitleLayout() {
    }
    
    ///Set up info layout within general view controller
    internal func setUpInfoLayout() {
    }
    
}
