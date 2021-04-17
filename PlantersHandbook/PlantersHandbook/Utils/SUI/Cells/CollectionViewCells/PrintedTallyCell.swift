//
//  CollectionViewCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-26.
//

import UIKit

///PrintedTallyCell.swift -  UICollectionViewCell representing a input in a printed tally sheet
class PrintedTallyCell: UICollectionViewCell {
    var input = SUI.label(title: "", fontSize: FontSize.medium)
    let bottomBar = SUI.underlineBar(color: .clear)
    
    ///Constructor that sets up the frame of the cell
    ///- Parameter frame: Frame of cell (x and y locations on screen and size)
    override init(frame: CGRect) {
        super.init(frame: .zero)
        generateLayout()
   }
    ///Creates layout for cell
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

    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
   required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}
