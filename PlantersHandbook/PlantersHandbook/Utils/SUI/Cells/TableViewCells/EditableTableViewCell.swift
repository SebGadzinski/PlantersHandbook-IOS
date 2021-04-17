//
//  EditableTableViewCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

///EditableTableViewCell.swift - Table view cell with a hamburger menu button 
class EditableTableViewCell: UITableViewCell {
    let hamburgerMenu = UIButton(type: .custom)
    
    ///Contructor initalizing fields required to operate UITableViewCell
    ///- Parameter style: Style for cell
    ///- Parameter reuseIdentifier: Reuse identifier for cell recycling
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        generateLayout()
    }

    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///Creates  layout for cell
    func generateLayout(){
        let hamburgerFileName = (traitCollection.userInterfaceStyle == .dark ? "hamburger_menu_white.png" : "hamburger_menu_dark.png")
        hamburgerMenu.setImage(UIImage(named: hamburgerFileName), for: .normal)
        hamburgerMenu.translatesAutoresizingMaskIntoConstraints = false
        
        [hamburgerMenu].forEach{contentView.addSubview($0)}

        hamburgerMenu.anchor(top: nil, leading: nil, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 10), size: .init(width:  40, height:  40))
        hamburgerMenu.anchorCenterY(to: contentView)
    }

}
