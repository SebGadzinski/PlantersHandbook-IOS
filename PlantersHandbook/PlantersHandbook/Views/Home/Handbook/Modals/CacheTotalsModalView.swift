//
//  CacheTotalsModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-06-12.
//

import UIKit

class CacheTotalsModalView: GeneralView {

    internal let titleLabel = SUI.label(title: "", fontSize: FontSize.largeTitle)
    internal let treesLabel = SUI.label(title: "Trees: ", fontSize: 100)
    internal let cashLabel = SUI.label(title: "Cash: ", fontSize: 100)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    ///Set up title layout within general view controller
    internal override func setUpTitleLayout(){
        super.setUpTitleLayout()
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    ///Set up info layout within general view controller
    internal override func setUpInfoLayout(){
        super.setUpInfoLayout()
        [treesLabel, cashLabel].forEach{infoLayout.addSubview($0)}
        
        treesLabel.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, size: .init(width: 0, height: infoLayout.frame.height/2))
        treesLabel.textColor = .systemGreen
        
        cashLabel.anchor(top: treesLabel.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
