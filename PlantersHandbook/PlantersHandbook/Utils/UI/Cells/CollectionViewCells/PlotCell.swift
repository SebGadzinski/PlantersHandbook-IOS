//
//  PlotCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-30.
//

import UIKit
import UnderLineTextField

class PlotCell: UICollectionViewCell {
    
    var number = label_number(title: nil)
    var plotOne = textField_bagUp()
    var plotTwo = textField_bagUp()
    let bottomBarOne = underLineBar(color: .systemOrange)
    let bottomBarTwo = underLineBar(color: .systemOrange)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeViews()
        generateConstraints()
   }
    
    func customizeViews(){
        plotOne.keyboardType = .numberPad
        plotTwo.keyboardType = .numberPad
    }
    
    func generateConstraints(){
        [number, plotOne, bottomBarOne, plotTwo, bottomBarTwo].forEach{contentView.addSubview($0)}
        backgroundColor = .systemBackground
        
        let contentFrame = contentView.frame
        
        //Number on left side
        number.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, size: .init(width: contentFrame.height, height: contentFrame.height))
        //Plot One with bottom bar
        plotOne.anchor(top: contentView.topAnchor, leading: number.trailingAnchor, bottom: nil, trailing: nil, size: .init(width: contentFrame.width*0.3, height: contentFrame.height*0.9))
        bottomBarOne.topAnchor.constraint(equalTo: plotOne.bottomAnchor).isActive = true
        bottomBarOne.leadingAnchor.constraint(equalTo: plotOne.leadingAnchor).isActive = true
        bottomBarOne.trailingAnchor.constraint(equalTo: plotOne.trailingAnchor).isActive = true
        bottomBarOne.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomBarOne.heightAnchor.constraint(equalToConstant: contentFrame.height*0.1).isActive = true
        //Plot two with bottom bar
        plotTwo.anchor(top: contentView.topAnchor, leading: plotOne.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 15, bottom: 0, right: 0) ,size: .init(width: contentFrame.width*0.3, height: contentFrame.height*0.9))
        bottomBarTwo.topAnchor.constraint(equalTo: plotTwo.bottomAnchor).isActive = true
        bottomBarTwo.leadingAnchor.constraint(equalTo: plotTwo.leadingAnchor).isActive = true
        bottomBarTwo.trailingAnchor.constraint(equalTo: plotTwo.trailingAnchor).isActive = true
        bottomBarTwo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomBarTwo.heightAnchor.constraint(equalToConstant: contentFrame.height*0.1).isActive = true
    }

   required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
}
    

