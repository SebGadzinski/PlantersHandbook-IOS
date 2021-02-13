//
//  GeneralViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-11.
//

import UIKit

class GeneralViewController: ProgramicVC, GeneralViewControllerInterface {

    internal let titleLayout = SUI_View(backgoundColor: .systemBackground)
    internal let infoLayout = SUI_View(backgoundColor: .systemBackground)
    
    internal override func setUpOverlay() {
        super.setUpOverlay()
        [titleLayout, infoLayout].forEach{backgroundView.addSubview($0)}
                
        titleLayout.anchor(top: backgroundView.topAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.25))
        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.7))
    }
    
    internal override func configureViews() {
        super.configureViews()
        setUpTitleLayout()
        setUpInfoLayout()
    }
    
    internal func setUpTitleLayout() {
        print("setUpTitleLayout")
    }
    
    internal func setUpInfoLayout() {
        print("setUpInfoLayout")
    }
    
}
