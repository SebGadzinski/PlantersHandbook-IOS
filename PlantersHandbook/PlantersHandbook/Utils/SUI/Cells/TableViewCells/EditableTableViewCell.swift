//
//  EditableTableViewCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

class EditableTableViewCell: UITableViewCell {
    let hamburgerMenu = UIButton(type: .custom)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        generateLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func generateLayout(){
        let hamburgerFileName = (traitCollection.userInterfaceStyle == .dark ? "hamburger_menu_white.png" : "hamburger_menu_dark.png")
        hamburgerMenu.setImage(UIImage(named: hamburgerFileName), for: .normal)
        hamburgerMenu.translatesAutoresizingMaskIntoConstraints = false
        
        [hamburgerMenu].forEach{contentView.addSubview($0)}

        hamburgerMenu.anchor(top: nil, leading: nil, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 10), size: .init(width:  40, height:  40))
        hamburgerMenu.anchorCenterY(to: contentView)
    }

}
