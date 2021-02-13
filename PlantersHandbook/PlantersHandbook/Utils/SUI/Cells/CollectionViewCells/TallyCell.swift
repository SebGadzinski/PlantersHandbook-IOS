//
//  TallyCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-18.
//

import UIKit

class TallyCell: UICollectionViewCell {
    var input = PH_TextField_BagUp()
    let bottomBar = SUI_View_UnderlineBar(color: .systemGreen)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        generateLayout()
   }
    
    func generateLayout(){
        contentView.addSubview(input)
        contentView.addSubview(bottomBar)
        backgroundColor = .systemBackground
        input.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        input.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        input.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bottomBar.anchor(top: input.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 1, bottom: 4, right: 1))
        bottomBar.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }

   required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}
