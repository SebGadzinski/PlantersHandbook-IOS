//
//  PlotCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-30.
//

import UIKit
import UnderLineTextField

///PlotCell.swift - UICollectionViewCell representing a PlotInput
class PlotCell: UICollectionViewCell {
    
    var number = PHUI.labelNumber(title: nil)
    var plotOne = PHUI.TextField_BagUp()
    var plotTwo = PHUI.TextField_BagUp()
    let bottomBarOne = SUI.underlineBar(color: .systemOrange)
    let bottomBarTwo = SUI.underlineBar(color: .systemOrange)
    
    ///Constructor that sets up the frame of the cell
    ///- Parameter frame: Frame of cell (x and y locations on screen and size)
    override init(frame: CGRect) {
        super.init(frame: frame)
        generateLayout()
   }
    
    ///Creates  layout for cell
    func generateLayout(){
        plotOne.keyboardType = .numberPad
        plotTwo.keyboardType = .numberPad
        
        [number, plotOne, bottomBarOne, plotTwo, bottomBarTwo].forEach{contentView.addSubview($0)}
        backgroundColor = .systemBackground
        
        let contentFrame = contentView.frame
        
        //Number on left side
        number.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, size: .init(width: contentFrame.height, height: contentFrame.height))
        //Plot One with bottom bar
        let plotInputWidth = (contentFrame.width - contentFrame.height) * 0.45
        plotOne.anchor(top: contentView.topAnchor, leading: number.trailingAnchor, bottom: nil, trailing: nil, size: .init(width: plotInputWidth, height: contentFrame.height*0.9))
        bottomBarOne.topAnchor.constraint(equalTo: plotOne.bottomAnchor).isActive = true
        bottomBarOne.leadingAnchor.constraint(equalTo: plotOne.leadingAnchor).isActive = true
        bottomBarOne.trailingAnchor.constraint(equalTo: plotOne.trailingAnchor).isActive = true
        bottomBarOne.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomBarOne.heightAnchor.constraint(equalToConstant: contentFrame.height*0.1).isActive = true
        //Plot two with bottom bar
        plotTwo.anchor(top: contentView.topAnchor, leading: plotOne.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 15, bottom: 0, right: 0) ,size: .init(width: plotInputWidth, height: contentFrame.height*0.9))
        bottomBarTwo.topAnchor.constraint(equalTo: plotTwo.bottomAnchor).isActive = true
        bottomBarTwo.leadingAnchor.constraint(equalTo: plotTwo.leadingAnchor).isActive = true
        bottomBarTwo.trailingAnchor.constraint(equalTo: plotTwo.trailingAnchor).isActive = true
        bottomBarTwo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomBarTwo.heightAnchor.constraint(equalToConstant: contentFrame.height*0.1).isActive = true
    }

    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
   required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
}
    

