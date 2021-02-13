//
//  TableViewCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

class CardCell: UICollectionViewCell {
    let containerView = UIView()
    let hamburgerMenu = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        generateLayout()
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func generateLayout(){
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = CornerRaduis.medium
        containerView.backgroundColor = .systemBackground
        containerView.layer.borderWidth = 0.1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.shadowColor =  UIColor.lightGray.cgColor
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOffset = CGSize(width: -1, height: 4)
        containerView.layer.shadowOpacity = 0.9
        containerView.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark ? StatisticColors.cardDark : StatisticColors.cardLight)
        
        containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: contentView.frame.height*0.1, left: contentView.frame.width*0.1, bottom: contentView.frame.height*0.1, right: contentView.frame.width*0.1), size: .init(width:  contentView.frame.width, height:  contentView.frame.height))
        let hamburgerFileName = (traitCollection.userInterfaceStyle == .dark ? "hamburger_menu_white.png" : "hamburger_menu_dark.png")
        hamburgerMenu.setImage(UIImage(named: hamburgerFileName), for: .normal)
        hamburgerMenu.translatesAutoresizingMaskIntoConstraints = false
        
        [hamburgerMenu].forEach{containerView.addSubview($0)}

        hamburgerMenu.anchor(top: containerView.topAnchor, leading: nil, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 10), size: .init(width:  40, height:  40))
    }

}
